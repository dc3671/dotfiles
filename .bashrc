# Path to your oh-my-bash installation.
export OSH='/home/zhenhuanc/.oh-my-bash'

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-bash is loaded.
# OSH_THEME="powerbash10k"
# OSH_THEME="bobby-python"
OSH_THEME="pzq"

completions=(git composer pip)

aliases=(general)

plugins=(git bashmarks)
# User configuration
export PATH="/bin:/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.local/bin:/usr/bin:/usr/sbin"
export PATH="/usr/local/mpi/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/ucx/bin:/opt/amazon/efa/bin:$PATH"
export PATH="$HOME/neovim/bin:$PATH"

export LD_LIBRARY_PATH="/usr/local/cuda/compat/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/usr/local/tensorrt/lib"

export SQUEUE_FORMAT="%.18i %.9P %.40j %.10u %.2t %.10M %.6D %R"

# Do not automatically activate the base environment
# during shell initialization.
export CONDA_AUTO_ACTIVATE_BASE=false

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

# my shell = interactive or login. ssh command shell (rsync/scp/git-over-ssh)
# is neither, but still sources this file -- its output = client-side noise.
_my_shell() { [[ $- == *i* ]] || shopt -q login_shell; }

# agent socket juggling spawns ssh-add/ssh-agent + rewrites ~/.ssh/auth_sock.
# my shells only; no agent churn per rsync connection.
_my_shell && source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/scripts/ssh-reconnect.sh"

alias sudo="sudo -E"
alias vi="vim"
alias cp="cp -r"
alias rm="rm -r"
alias mkdir="mkdir -p"
alias sa="sudo apt-get"
alias sd="sudo dnf"
alias ll="ls -lh"

# Two miniforge installs, split by arch: arm64 = compute node/container,
# x86 = login node. Wrong arch conda = ENOEXEC, then bash runs conda's python
# source as shell script ("import: command not found").
if [ "$(uname -m)" = "aarch64" ]; then
    __mf_root="$HOME/scratch/miniforge3"
else
    __mf_root="$HOME/scratch/miniforge3_x86"
fi

# Conda only for my shells + pyxis container shells (pyxis early-injects
# CONDA_ENV via `srun --container-env=CONDA_ENV`, before this file sources).
# No install for this arch / scratch not mounted -> skip, stay quiet.
if { _my_shell || [ -n "${CONDA_ENV:-}" ]; } && [ -x "$__mf_root/bin/conda" ]; then

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$__mf_root/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$__mf_root/etc/profile.d/conda.sh" ]; then
        . "$__mf_root/etc/profile.d/conda.sh"
    else
        export PATH="$__mf_root/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
#
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE="$__mf_root/bin/mamba";
export MAMBA_ROOT_PREFIX="$__mf_root";
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

if [ "${CONDA_ENV:-}" = "null" ]; then
    # opt-out: keep container system trtllm (/usr/local), no conda. Needed for
    # login shells in release images -- `bash -l worker.sh`, `srun --pty bash -l`.
    :
elif [ -n "${CONDA_ENV:-}" ] && type conda >/dev/null 2>&1; then
    conda activate "$CONDA_ENV"
elif _my_shell; then
    # default env, my shells only. batch/pyxis must name CONDA_ENV.
    conda activate llm
fi

fi
unset __mf_root
