#!/bin/bash

# SSH agent: prefer the forwarded agent bound to a shared $HOME socket, and fall
# back to a persistent local agent when the laptop is disconnected.
#
# Design goals (see git history / dotfiles notes):
#   * tmp-dir churn: sshd's default forwarded socket lives in a per-login
#     pam_namespace /tmp mount that tmux (pinned to a different namespace) cannot
#     reach, and the dir changes every login. We avoid /tmp entirely: the laptop
#     RemoteForwards to a FIXED $HOME path, and tmux is pinned to a FIXED symlink.
#   * agent lifetime: the local fallback agent is a durable SINGLETON started with
#     `setsid` so it is detached from the login shell's session and survives
#     logout/disconnect. We reuse it across logins instead of respawning (which
#     used to leak dozens of orphaned ssh-agents).
#   * minimal ~/.ssh: only two entries live there -- the `auth_sock` symlink and
#     the laptop RemoteForward target. The agent socket + env-record live in ~/.tmp.
#
# Laptop-side (~/.ssh/config) to set up the shared forwarded socket:
#
#     Host <this-host>
#         ForwardAgent yes
#         RemoteForward /home/zhenhuanc/.ssh/agent.forward.sock ${SSH_AUTH_SOCK}
#         StreamLocalBindUnlink yes
#
# On compute nodes / inside containers the login-node forwarded socket is
# unreachable (different host), so we ignore any inherited SSH_AUTH_SOCK and start
# a fresh per-host local agent from scratch.
#
# ssh-add -l rc: 0 = keys present, 1 = agent alive but empty, 2 = unreachable.

_is_on_compute_or_container() {
    [ -n "$SLURM_JOB_ID" ] && return 0
    # Slurm harvests the user environment BEFORE SLURM_JOB_ID exists, by running
    #   su - <user> -c '...; /usr/sbin/slurmstepd getenv; ...'
    # ON THE COMPUTE NODE. That is a login shell, so without these two checks the
    # login-node branch runs there and relinks the NFS-shared ~/.ssh/auth_sock at a
    # compute node's socket -- measured: auth_sock -> ssh-agent.<compute-node>.sock,
    # every login-node shell then got "Error connecting to agent: Connection refused".
    case "$(ps -o args= -p $PPID 2>/dev/null)" in *slurmstepd*) return 0 ;; esac
    pgrep -x slurmd &>/dev/null && return 0   # compute nodes run slurmd; login nodes do not
    { [ -n "$ENROOT_PID" ] || [ -n "$PYXIS_CONTAINER_NAME" ] || [ -n "$container" ]; } && return 0
    { [ -f /.dockerenv ] || [ -f /run/.containerenv ]; } && return 0
    return 1
}

# Does this shell have a human behind it? srun --pty / tmux: yes. A batch step:
# no -- pyxis runs the job command through a LOGIN shell (ENROOT_LOGIN_SHELL
# defaults true), so this file is sourced there whenever $HOME is bind-mounted.
_want_agent() { [[ $- == *i* ]] && [ -t 0 ]; }

# Kill leaked local ssh-agents. Keeps agents referenced by a *.env record and the
# one bound to ~/.ssh/auth_sock.live (another tool's temp agent). One-shot helper;
# NOT run automatically (racy across concurrent logins) -- call by hand.
ssh_agent_reap() {
    local f pid p killed=0
    local -a keep=()
    for f in "$HOME"/.tmp/ssh-agent.*.env "$HOME"/.ssh/agent.env; do
        [ -f "$f" ] || continue
        pid=$(sed -n 's/.*SSH_AGENT_PID=\([0-9]*\).*/\1/p' "$f")
        [ -n "$pid" ] && keep+=("$pid")
    done
    for pid in $(pgrep -u "$USER" -x ssh-agent); do
        tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null | grep -q 'auth_sock.live' && keep+=("$pid")
    done
    for p in $(pgrep -u "$USER" -x ssh-agent); do
        printf ' %s ' "${keep[@]}" | grep -q " $p " && continue
        kill "$p" 2>/dev/null && killed=$((killed + 1))
    done
    echo "ssh_agent_reap: killed $killed leaked agent(s), kept ${#keep[@]}"
}

_update_ssh_auth_sock() {
    local fwd="$HOME/.ssh/agent.forward.sock"   # laptop RemoteForward target (shared $HOME)
    local fixed="$HOME/.ssh/auth_sock"          # tmux fixed path (symlink we manage)
    local sockdir="$HOME/.tmp"
    local host; host=$(hostname -s)
    local own_sock="$sockdir/ssh-agent.$host.sock"   # our singleton local agent socket
    local agent_env="$sockdir/ssh-agent.$host.env"   # its PID/socket record

    # Is $1 a live agent socket? (ssh-add -l returns rc 0 or 1)
    _sock_alive() {
        [ -S "$1" ] || return 1
        SSH_AUTH_SOCK="$1" ssh-add -l &>/dev/null
        local r=$?
        [ $r -eq 0 ] || [ $r -eq 1 ]
    }

    _ssh_add_keys() {
        [ -f "$HOME/.ssh/id_ed25519" ] && ssh-add "$HOME/.ssh/id_ed25519" &>/dev/null
        [ -f "$HOME/.ssh/id_rsa" ] && ssh-add "$HOME/.ssh/id_rsa" &>/dev/null
    }

    # Ensure a live singleton local agent bound to $own_sock. Reuse the recorded
    # one if still alive; otherwise spawn a fresh, session-detached agent. On
    # return SSH_AUTH_SOCK/SSH_AGENT_PID point at it.
    _ensure_local_agent() {
        if [ -f "$agent_env" ]; then
            source "$agent_env" &>/dev/null
            if _sock_alive "$SSH_AUTH_SOCK"; then
                ssh-add -l &>/dev/null || _ssh_add_keys   # rc 1 (empty) -> load keys
                # mtime = last use, so _prune_stale_agents never reaps a live agent
                touch "$agent_env" "$SSH_AUTH_SOCK" 2>/dev/null
                export SSH_AUTH_SOCK SSH_AGENT_PID
                return 0
            fi
        fi
        mkdir -p "$sockdir"
        rm -f "$own_sock"
        # setsid: detach from the login shell's session so the agent survives logout.
        local out
        out=$(setsid ssh-agent -a "$own_sock" -s 2>/dev/null)
        eval "$out"
        printf 'export SSH_AUTH_SOCK=%q\nexport SSH_AGENT_PID=%q\n' \
            "$SSH_AUTH_SOCK" "$SSH_AGENT_PID" >| "$agent_env"
        _ssh_add_keys
        export SSH_AUTH_SOCK SSH_AGENT_PID
        # Forensics: who asked for an agent. Cheap (one line per fresh spawn) and
        # the only way to attribute a compute-node agent to its caller after the
        # job's namespace is gone.
        { printf '%s host=%s job=%s dollar=%s tty0=%s\n    parent: %s\n    grandparent: %s\n' \
            "$(date -Is 2>/dev/null)" "$host" "${SLURM_JOB_ID:-none}" "$-" \
            "$([ -t 0 ] && echo y || echo n)" \
            "$(ps -o args= -p $PPID 2>/dev/null)" \
            "$(ps -o args= -p "$(ps -o ppid= -p $PPID 2>/dev/null | tr -d ' ')" 2>/dev/null)"
        } >> "$sockdir/ssh-agent-spawn.log" 2>/dev/null
    }

    # Drop other hosts' records once they go a month unused. Compute-node records
    # used to pile up one per node per job (~440 pairs on lustre before this file
    # stopped spawning agents in batch steps). Reuse touches them, so age = idle.
    _prune_stale_agents() {
        local stamp="$sockdir/.ssh-agent-prune.stamp" f h
        [ -n "$(find "$stamp" -maxdepth 0 -mtime -1 2>/dev/null)" ] && return   # once a day
        : >| "$stamp"
        # trailing slash: $sockdir is a symlink to lustre, and find would stop at it
        for f in $(find "$sockdir/" -maxdepth 1 -name 'ssh-agent.*.env' -mtime +30 2>/dev/null); do
            h=${f##*/ssh-agent.}; h=${h%.env}
            [ "$h" = "$host" ] && continue
            rm -f "$f" "$sockdir/ssh-agent.$h.sock"
        done
    }

    # Compute node / container: the inherited login-forwarded socket is on another
    # host and unreachable. Never touch the ~/.ssh symlink here (NFS-shared, would
    # clobber the login node's).
    #
    # Batch steps get NO agent: nothing there authenticates, and spawning one loaded
    # the private key on every node of every job. Measured: a home-mounted container
    # spawns the agent and loads the key; the same image with
    # --no-container-mount-home never sources this file at all.
    if _is_on_compute_or_container; then
        if _want_agent; then
            _ensure_local_agent
            return
        fi
        # Log near-misses (tty but not interactive) for attribution; normally none.
        [ -t 0 ] && { printf '%s SKIP host=%s job=%s dollar=%s\n    parent: %s\n    grandparent: %s\n' \
            "$(date -Is 2>/dev/null)" "$host" "${SLURM_JOB_ID:-none}" "$-" \
            "$(ps -o args= -p $PPID 2>/dev/null)" \
            "$(ps -o args= -p "$(ps -o ppid= -p $PPID 2>/dev/null | tr -d ' ')" 2>/dev/null)"
        } >> "$sockdir/ssh-agent-spawn.log" 2>/dev/null
        # Adopt an agent already running on this node; never spawn, never load keys.
        unset SSH_AUTH_SOCK SSH_AGENT_PID
        if [ -f "$agent_env" ]; then
            source "$agent_env" &>/dev/null
            if _sock_alive "${SSH_AUTH_SOCK:-}"; then
                export SSH_AUTH_SOCK SSH_AGENT_PID
            else
                unset SSH_AUTH_SOCK SSH_AGENT_PID
            fi
        fi
        return
    fi

    # ---- login node ----

    _prune_stale_agents   # login node only: one shell at a time, not 16 job nodes

    # 1. Forwarded agent on the shared $HOME socket -- preferred whenever the
    #    laptop is connected.
    if _sock_alive "$fwd"; then
        ln -sf "$fwd" "$fixed"
        export SSH_AUTH_SOCK="$fixed"
        return
    fi

    # 2. A forwarded agent already in our environment (e.g. a fresh login shell
    #    before tmux pins the fixed path), and not our own managed symlink.
    if [ -n "$SSH_AUTH_SOCK" ] && [ "$SSH_AUTH_SOCK" != "$fixed" ] && _sock_alive "$SSH_AUTH_SOCK"; then
        ln -sf "$SSH_AUTH_SOCK" "$fixed"
        export SSH_AUTH_SOCK="$fixed"
        return
    fi

    # 3. Laptop disconnected: point the fixed symlink at the durable local agent.
    _ensure_local_agent
    ln -sf "$own_sock" "$fixed"
    export SSH_AUTH_SOCK="$fixed"
}
_update_ssh_auth_sock

# reset DISPLAY
# export DISPLAY="$(tmux show-env | sed -n 's/^DISPLAY=//p')"
