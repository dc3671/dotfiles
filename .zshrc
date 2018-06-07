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
ZSH_THEME="ys"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git history-substring-search tmux)

# User configuration

export HOME=~
export FONTS_HOME="/usr/share/fonts"
export PYTHON_HOME="$HOME/.local/lib/python3.6:/usr/lib/python3.6:/usr/lib64/python3.6:/usr/include/python3.6"
export GCC_HOME="/usr/lib/gcc/x86_64-redhat-linux/4.9.2"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk"
export CUDA_HOME="/usr/local/cuda-8.0"
export MINICONDA_HOME=~/miniconda3
export ANACONDA_HOME="/opt/anaconda/anaconda3"

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

export PATH="/bin:/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.local/bin:/usr/bin:/usr/sbin"
export PATH="$FONTS_HOME:$PATH"
export PATH="$PYTHON_HOME:$PATH"
export PATH="$GCC_HOME/include/:$PATH"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$CUDA_HOME/bin:$PATH"
export PATH="$MINICONDA_HOME/bin:$PATH"
export PATH="$ANACONDA_HOME/bin:$PATH"

export LD_LIBRARY_PATH="/usr/lib:/usr/local/lib:$HOME/.local/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/.local/cuda/lib64"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$CUDA_HOME/extras/CUPTI/lib64"

export TERM="xterm-256color"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export GIT_SSL_NO_VERIFY=1
export EDITOR='vim'
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
umask 002

source $ZSH/oh-my-zsh.sh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

unsetopt PROMPT_SP

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases

alias sudo="sudo -E"
alias la='ls -a'
alias lh='ls -a | egrep "^\."'
alias vi='vim'
alias cp='cp -r'
alias rm='rm -r'
alias mkdir='mkdir -p'
#alias tmux='tmux -2'
#alias npm='cnpm'
alias sa="sudo apt-get"
#alias python="python3"
#alias pip="pip3"
alias fq='~/xx-net.sh'

alias -s html=vi
alias -s rb=vi
alias -s py=vi
alias -s js=vi
alias -s c=vi
alias -s java=vi
alias -s txt=vi
alias -s gz='tar -xzvf'
alias -s tgz='tar -xzvf'
alias -s zip='unzip'
alias -s bz2='tar -xjvf'

alias gf='git flow'
alias ga='git add'
alias gp='git push'
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gm='git commit -m'
alias gma='git commit -am'
alias gb='git branch'
alias gck='git checkout'
alias gra='git remote add'
alias grr='git remote rm'
alias gpu='git pull'
alias gcl='git clone'
alias gta='git tag -a -m'
