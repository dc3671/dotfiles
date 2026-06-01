#!/bin/bash

# SSH agent: prefer forwarded agent, fall back to persistent local agent
# ssh-add -l: 0 = keys present, 1 = agent alive but no keys, 2 = agent unreachable
#
# $HOME is NFS-shared across login and compute nodes. To avoid the compute
# node clobbering the login node's auth_sock symlink, use a per-host suffix
# on compute/container. Containers inherit hostname from the host (pyxis
# default), so a container shares the socket with its compute node.
_is_on_compute_or_container() {
    [ -n "$SLURM_JOB_ID" ] && return 0
    [ -n "$ENROOT_PID" ] || [ -n "$PYXIS_CONTAINER_NAME" ] || [ -n "$container" ] && return 0
    [ -f /.dockerenv ] || [ -f /run/.containerenv ] && return 0
    return 1
}

_update_ssh_auth_sock() {
    local fixed agent_env rc
    if _is_on_compute_or_container; then
        fixed="$HOME/.ssh/auth_sock.$(hostname -s)"
        agent_env="$HOME/.ssh/agent.$(hostname -s).env"
    else
        fixed="$HOME/.ssh/auth_sock"
        agent_env="$HOME/.ssh/agent.env"
    fi

    _ssh_add_keys() {
        [ -f "$HOME/.ssh/id_ed25519" ] && ssh-add "$HOME/.ssh/id_ed25519" &>/dev/null
        [ -f "$HOME/.ssh/id_rsa" ] && ssh-add "$HOME/.ssh/id_rsa" &>/dev/null
    }

    # If we have a live forwarded agent (not our own symlink), update the symlink
    if [ -n "$SSH_AUTH_SOCK" ] && [ "$SSH_AUTH_SOCK" != "$fixed" ] && [ -S "$SSH_AUTH_SOCK" ]; then
        ssh-add -l &>/dev/null
        rc=$?
        if [ $rc -eq 0 ] || [ $rc -eq 1 ]; then
            ln -sf "$SSH_AUTH_SOCK" "$fixed"
            export SSH_AUTH_SOCK="$fixed"
            return
        fi
    fi

    # Point to the fixed path
    export SSH_AUTH_SOCK="$fixed"

    # If the symlink is alive and usable, we're done
    if [ -S "$fixed" ]; then
        ssh-add -l &>/dev/null
        rc=$?
        if [ $rc -eq 0 ] || [ $rc -eq 1 ]; then
            return
        fi
    fi

    # Symlink is dead — try reusing an existing local agent from agent.env
    if [ -f "$agent_env" ]; then
        source "$agent_env" &>/dev/null
        if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ]; then
            ssh-add -l &>/dev/null
            rc=$?
            if [ $rc -eq 0 ] || [ $rc -eq 1 ]; then
                [ $rc -eq 1 ] && _ssh_add_keys
                ln -sf "$SSH_AUTH_SOCK" "$fixed"
                export SSH_AUTH_SOCK="$fixed"
                return
            fi
        fi
    fi

    # Start fresh local agent with socket in ~/.tmp so it's visible inside
    # containers (pyxis bind-mounts $HOME but not /tmp). Per-host suffix
    # avoids collisions on shared NFS.
    mkdir -p "$HOME/.tmp"
    local own_sock="$HOME/.tmp/ssh-agent.$(hostname -s).sock"
    rm -f "$own_sock"
    eval "$(ssh-agent -s -a "$own_sock")" &>/dev/null
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK; export SSH_AGENT_PID=$SSH_AGENT_PID" >| "$agent_env"
    _ssh_add_keys
    ln -sf "$SSH_AUTH_SOCK" "$fixed"
    export SSH_AUTH_SOCK="$fixed"
}
_update_ssh_auth_sock

# reset DISPLAY
# export DISPLAY="$(tmux show-env | sed -n 's/^DISPLAY=//p')"
