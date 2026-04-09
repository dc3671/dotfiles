#!/bin/bash

# SSH agent: prefer forwarded agent, fall back to persistent local agent
_update_ssh_auth_sock() {
    local fixed="$HOME/.ssh/auth_sock"
    local agent_env="$HOME/.ssh/agent.env"

    # If we have a live forwarded agent (not our own symlink), update the symlink
    if [ -n "$SSH_AUTH_SOCK" ] && [ "$SSH_AUTH_SOCK" != "$fixed" ] && [ -S "$SSH_AUTH_SOCK" ]; then
        ln -sf "$SSH_AUTH_SOCK" "$fixed"
        export SSH_AUTH_SOCK="$fixed"
        return
    fi

    # Point to the fixed path
    export SSH_AUTH_SOCK="$fixed"

    # If the symlink is alive and usable, we're done
    # (ssh-add -l exits 0 with keys, 1 with no keys, 2 if can't connect)
    if [ -S "$fixed" ]; then
        ssh-add -l &>/dev/null
        local rc=$?
        if [ $rc -eq 0 ] || [ $rc -eq 1 ]; then
            return
        fi
    fi

    # Symlink is dead — try reusing an existing local agent from agent.env
    if [ -f "$agent_env" ]; then
        source "$agent_env" &>/dev/null
        if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ]; then
            ssh-add -l &>/dev/null
            local rc=$?
            if [ $rc -eq 0 ] || [ $rc -eq 1 ]; then
                ln -sf "$SSH_AUTH_SOCK" "$fixed"
                export SSH_AUTH_SOCK="$fixed"
                return
            fi
        fi
    fi

    # Start fresh local agent
    eval "$(ssh-agent -s)" &>/dev/null
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK; export SSH_AGENT_PID=$SSH_AGENT_PID" > "$agent_env"
    [ -f "$HOME/.ssh/id_ed25519" ] && ssh-add "$HOME/.ssh/id_ed25519" &>/dev/null
    [ -f "$HOME/.ssh/id_rsa" ] && ssh-add "$HOME/.ssh/id_rsa" &>/dev/null
    ln -sf "$SSH_AUTH_SOCK" "$fixed"
    export SSH_AUTH_SOCK="$fixed"
}
_update_ssh_auth_sock

# reset DISPLAY
export DISPLAY="$(tmux show-env | sed -n 's/^DISPLAY=//p')"
