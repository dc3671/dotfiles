# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -r $HOME/.local/share/nvim/lazy/fzf ]]; then
  export FZF_BASE=$HOME/.local/share/nvim/lazy/fzf
fi
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

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git gitfast dirhistory ssh-agent tmux python pip docker command-not-found zsh-autosuggestions zsh-syntax-highlighting fzf)

# User configuration
export HOME=~

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# fix WSL2 clipboard
#export DISPLAY="$(/sbin/ip route | awk '/default/ { print $3 }'):0"

export PATH="/bin:/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.local/bin:/usr/bin:/usr/sbin"
export PATH="/usr/local/cmake/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/mpi/bin:/usr/local/ucx/bin:/opt/amazon/efa/bin:/opt/tensorrt/bin:$PATH"
export PATH="$HOME/neovim/bin:$PATH"

export LD_LIBRARY_PATH="/opt/nvidia/nvda_nixl/lib/x86_64-linux-gnu:/opt/nvidia/nvda_nixl/lib64:/usr/local/ucx/lib:/usr/local/tensorrt/lib:/usr/local/cuda/lib64:/usr/local/cuda/compat/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64"
export PYTHONUSERBASE="intentionally-disabled"

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

zstyle :omz:plugins:ssh-agent agent-forwarding on >/dev/null 2>&1
#zstyle :omz:plugins:ssh-agent identities id_rsa

source $ZSH/oh-my-zsh.sh

# [ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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
