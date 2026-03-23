# Enable the subsequent settings only in interactive sessions
# case $- in
#   *i*) ;;
#     *) return;;
# esac

# Path to your oh-my-bash installation.
export OSH='/home/zhenhuanc/.oh-my-bash'

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-bash is loaded.
OSH_THEME="powerbash10k"
# disable git status for big repos
THEME_SHOW_SCM=false
THEME_SHOW_PYTHON=true

completions=(git composer ssh pip)

aliases=(general)

plugins=(git bashmarks)
# User configuration
export PATH="/bin:/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.local/bin:/usr/bin:/usr/sbin"
export PATH="/usr/local/mpi/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/ucx/bin:/opt/amazon/efa/bin:$PATH"
export PATH="$HOME/neovim/bin:$PATH"

export LD_LIBRARY_PATH="/usr/local/cuda/compat/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/usr/local/tensorrt/lib"

export TERM="xterm-256color"
export GIT_SSL_NO_VERIFY=1
export EDITOR="nvim"
umask 002
# On some clusters, max process is limited
pids_max_limit="/sys/fs/cgroup/user.slice/user-$(id -u $(whoami)).slice/pids.max"
if [[ -e $pids_max_limit ]] && [[ $(cat $pids_max_limit) != "max" ]]; then
    ulimit -u $(cat /sys/fs/cgroup/user.slice/user-$(id -u $(whoami)).slice/pids.max)
    ulimit -n $(cat /sys/fs/cgroup/user.slice/user-$(id -u $(whoami)).slice/pids.max)
else
    ulimit -u 131072
    ulimit -n 131072
fi

[ -f "$OSH"/oh-my-bash.sh ] && source "$OSH"/oh-my-bash.sh
export _ble_contrib_fzf_base=~/.local/share/nvim/lazy/fzf
[ -f ~/ble.sh/out/ble.sh ] && source -- ~/ble.sh/out/ble.sh

# SSH agent: prefer forwarded agent, fall back to persistent local agent
_update_ssh_auth_sock() {
    local fixed="$HOME/.ssh/auth_sock"
    local agent_env="$HOME/.ssh/agent.env"
    # If we have a live forwarded agent, update the symlink
    if [ -n "$SSH_AUTH_SOCK" ] && [ "$SSH_AUTH_SOCK" != "$fixed" ]; then
        ln -sf "$SSH_AUTH_SOCK" "$fixed"
        return
    fi
    # If the symlink is dead (laptop disconnected), start a local agent
    if [ ! -S "$fixed" ] || ! ssh-add -l &>/dev/null; then
        # Reuse existing local agent if alive
        if [ -f "$agent_env" ]; then
            source "$agent_env" &>/dev/null
            if [ -S "$SSH_AUTH_SOCK" ] && ssh-add -l &>/dev/null; then
                ln -sf "$SSH_AUTH_SOCK" "$fixed"
                return
            fi
        fi
        # Start fresh local agent
        eval "$(ssh-agent -s)" &>/dev/null
        echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK; export SSH_AGENT_PID=$SSH_AGENT_PID" > "$agent_env"
        # Auto-add key if it exists (passphrase-less, or use keychain for passphrase)
        [ -f "$HOME/.ssh/id_ed25519" ] && ssh-add "$HOME/.ssh/id_ed25519" &>/dev/null
        [ -f "$HOME/.ssh/id_rsa" ] && ssh-add "$HOME/.ssh/id_rsa" &>/dev/null
        ln -sf "$SSH_AUTH_SOCK" "$fixed"
    fi
}
_update_ssh_auth_sock
unset -f _update_ssh_auth_sock

alias sudo="sudo -E"
alias vi="vim"
alias cp="cp -r"
alias rm="rm -r"
alias mkdir="mkdir -p"
alias sa="sudo apt-get"
alias sd="sudo dnf"
