#!/bin/bash

# SSH agent: prefer the forwarded agent bound to a shared $HOME socket, and fall
# back to a persistent local agent when the laptop is disconnected.
#
# Why a $HOME socket instead of the default /tmp one: this cluster uses
# pam_namespace to polyinstantiate /tmp per login session, so sshd's default
# forwarded socket (/tmp/ssh-*/agent.*) lives in that session's private mount
# namespace and is invisible to tmux (which is pinned to a different namespace).
# A socket under $HOME (NFS) is visible in every namespace. Set up laptop-side:
#
#     Host <this-host>
#         ForwardAgent yes
#         RemoteForward /home/zhenhuanc/.ssh/agent.forward.sock ${SSH_AUTH_SOCK}
#         StreamLocalBindUnlink yes
#
# Caveat: a unix socket only works on the host that bound it. On compute nodes
# the login-node forwarded socket is unreachable (ssh-add returns rc 2), so we
# transparently fall back to a per-host local agent there.
#
# ssh-add -l rc: 0 = keys present, 1 = agent alive but empty, 2 = unreachable.
_is_on_compute_or_container() {
    [ -n "$SLURM_JOB_ID" ] && return 0
    { [ -n "$ENROOT_PID" ] || [ -n "$PYXIS_CONTAINER_NAME" ] || [ -n "$container" ]; } && return 0
    { [ -f /.dockerenv ] || [ -f /run/.containerenv ]; } && return 0
    return 1
}

_update_ssh_auth_sock() {
    local fwd="$HOME/.ssh/agent.forward.sock"   # RemoteForward target (shared $HOME)
    local fixed="$HOME/.ssh/auth_sock"          # tmux fixed path (symlink we manage)
    local agent_env compute rc
    if _is_on_compute_or_container; then
        compute=1
        agent_env="$HOME/.ssh/agent.$(hostname -s).env"
    else
        compute=0
        agent_env="$HOME/.ssh/agent.env"
    fi

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

    # Adopt a live socket: on the login node repoint the fixed symlink and use
    # it; on compute/container just export the real path (no symlink touched on
    # the NFS-shared $HOME).
    _adopt() {
        if [ "$compute" -eq 1 ]; then
            export SSH_AUTH_SOCK="$1"
        else
            ln -sf "$1" "$fixed"
            export SSH_AUTH_SOCK="$fixed"
        fi
    }

    # 1. Forwarded agent on the shared $HOME socket — preferred whenever the
    #    laptop is connected. Dead here on compute nodes, so we fall through.
    if _sock_alive "$fwd"; then
        _adopt "$fwd"
        return
    fi

    # 2. A forwarded agent already in our environment (e.g. a fresh login shell
    #    before tmux pins the fixed path), and not our own managed symlink.
    if [ -n "$SSH_AUTH_SOCK" ] && [ "$SSH_AUTH_SOCK" != "$fixed" ] && _sock_alive "$SSH_AUTH_SOCK"; then
        _adopt "$SSH_AUTH_SOCK"
        return
    fi

    # 3. Login node: the fixed symlink still points at a live agent (e.g. a local
    #    fallback agent from a prior shell) — keep using it.
    if [ "$compute" -eq 0 ] && _sock_alive "$fixed"; then
        export SSH_AUTH_SOCK="$fixed"
        return
    fi

    # 4. Reuse a persistent local agent recorded in agent.env.
    if [ -f "$agent_env" ]; then
        source "$agent_env" &>/dev/null
        if [ -S "$SSH_AUTH_SOCK" ]; then
            ssh-add -l &>/dev/null
            rc=$?
            if [ $rc -eq 0 ] || [ $rc -eq 1 ]; then
                [ $rc -eq 1 ] && _ssh_add_keys
                _adopt "$SSH_AUTH_SOCK"
                return
            fi
        fi
    fi

    # 5. Start a fresh local agent. Socket lives in ~/.tmp (under $HOME) so it's
    #    visible inside containers and across mount namespaces; per-host suffix
    #    avoids collisions on shared NFS.
    mkdir -p "$HOME/.tmp"
    local own_sock="$HOME/.tmp/ssh-agent.$(hostname -s).sock"
    rm -f "$own_sock"
    eval "$(ssh-agent -s -a "$own_sock")" &>/dev/null
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK; export SSH_AGENT_PID=$SSH_AGENT_PID" >| "$agent_env"
    _ssh_add_keys
    _adopt "$SSH_AUTH_SOCK"
}
_update_ssh_auth_sock

# reset DISPLAY
# export DISPLAY="$(tmux show-env | sed -n 's/^DISPLAY=//p')"
