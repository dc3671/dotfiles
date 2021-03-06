# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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
plugins=(git-extras git-flow-avh history-substring-search dirhistory ssh-agent tmux npm yarn python pip docker command-not-found zsh-autosuggestions)

# User configuration

export HOME=~
export LLVM_HOME="/usr/lib/llvm-5.0"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export JAVA_HOME="/usr/lib/jvm/default-java"
export GOPATH="$HOME/golang"
export GOROOT="/usr/local/opt/go/libexec"
export NVIDIA_HOME="/usr/local/nvidia"

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

export PATH="/bin:/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.local/bin:/usr/bin:/usr/sbin"
export PATH="$LLVM_HOME/bin:$PATH"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export PATH="$GOROOT/bin:$PATH"
export PATH="$NVIDIA_HOME/bin:$PATH"

export LD_LIBRARY_PATH="$NVIDIA_HOME/lib64"
export LIBRARY_PATH=$LD_LIBRARY_PATH

export TERM="xterm-256color"
export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export GIT_SSL_NO_VERIFY=1
export EDITOR="vim"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
umask 002

zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent identities id_rsa

source $ZSH/oh-my-zsh.sh

[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

unsetopt PROMPT_SP

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases

alias sudo="sudo -E"
alias la="ls -a"
alias lh="ls -a | egrep "^\.""
alias vi="vim"
alias cp="cp -r"
alias rm="rm -r"
alias mkdir="mkdir -p"
#alias tmux="tmux -2"
#alias npm="cnpm"
alias sa="sudo apt-get"

alias gf="git flow"
alias ga="git add"
alias gp="git push"
alias gl="git log"
alias gs="git status"
alias gd="git diff"
alias gc="git commit"
alias gm="git commit -m"
alias gma="git commit -am"
alias gb="git branch"
alias gck="git checkout"
alias gr="git rebase"
alias gra="git remote add"
alias grr="git remote rm"
alias gpu="git pull"
alias gcl="git clone"
alias gta="git tag -a -m"
