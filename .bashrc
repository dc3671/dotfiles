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
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export _ble_contrib_fzf_base=~/fzf
[ -f ~/ble.sh/out/ble.sh ] && source -- ~/ble.sh/out/ble.sh

alias sudo="sudo -E"
alias vi="vim"
alias cp="cp -r"
alias rm="rm -r"
alias mkdir="mkdir -p"
alias sa="sudo apt-get"
alias sd="sudo dnf"
