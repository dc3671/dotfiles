# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.

#ZSH_THEME="bureau"
#ZSH_THEME="amuse"
#ZSH_THEME="avit"
#ZSH_THEME="bira"
#ZSH_THEME="sporty_256"
#ZSH_THEME="kardan"
#ZSH_THEME="powerline"
#ZSH_THEME="agnoster"
#ZSH_THEME="afowler"
#ZSH_THEME="aussiegeek"
#ZSH_THEME="frisk"
#ZSH_THEME="mortalscumbag"
#ZSH_THEME="ys"
ZSH_THEME="powerlevel10k/powerlevel10k"

if [[ -r $HOME/.local/share/nvim/lazy/fzf ]]; then
  export FZF_BASE=$HOME/.local/share/nvim/lazy/fzf
fi

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git gitfast dirhistory tmux python pip zsh-autosuggestions zsh-syntax-highlighting fzf)

# User configuration
export HOME=~

# Will prevent tmux not showing UTF-8 characters correctly
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# fix WSL2 clipboard
#export DISPLAY="$(/sbin/ip route | awk '/default/ { print $3 }'):0"

export PATH="/bin:/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.local/bin:/usr/bin:/usr/sbin"
export PATH="/usr/local/cmake/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/mpi/bin:/usr/local/ucx/bin:/opt/amazon/efa/bin:/opt/tensorrt/bin:$PATH"
export PATH="$HOME/neovim/bin:$HOME/node/bin:$HOME/zsh/bin:$PATH"

export LD_LIBRARY_PATH="/opt/nvidia/nvda_nixl/lib/x86_64-linux-gnu:/opt/nvidia/nvda_nixl/lib64:/usr/local/ucx/lib:/usr/local/tensorrt/lib:/usr/local/cuda/lib64:/usr/local/cuda/compat/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64"
export PYTHONUSERBASE="intentionally-disabled"

# export TMPDIR="$HOME/scratch/.tmp"

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
fi

source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source "$(dirname "$(readlink -f "${(%):-%x}")")/scripts/ssh-reconnect.sh"

unsetopt PROMPT_SP
setopt ignoreeof

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias sudo="sudo -E"
alias vi="vim"
alias cp="cp -r"
alias rm="rm -r"
alias mkdir="mkdir -p"
alias sa="sudo apt-get"
alias sd="sudo dnf"
alias salloc="SHELL=/bin/bash salloc"

# Two miniforge installs, split by arch: arm64 = compute node/container,
# x86 = login node. Wrong arch conda = ENOEXEC, then shell runs conda's python
# source as shell script ("import: command not found"). Keep in sync with
# .bashrc. No install / scratch not mounted -> skip, stay quiet.
if [ "$(uname -m)" = "aarch64" ]; then
    __mf_root="$HOME/scratch/miniforge3"
else
    __mf_root="$HOME/scratch/miniforge3_x86"
fi

if [ -x "$__mf_root/bin/conda" ]; then

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$__mf_root/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
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


# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE="$__mf_root/bin/mamba";
export MAMBA_ROOT_PREFIX="$__mf_root";
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

# .zshrc = interactive shells only, so no login/interactive guard needed here.
# CONDA_ENV honored for parity with .bashrc.
if [ "${CONDA_ENV:-}" = "null" ]; then
    :
elif [ -n "${CONDA_ENV:-}" ]; then
    conda activate "$CONDA_ENV"
else
    conda activate llm
fi

fi
unset __mf_root
