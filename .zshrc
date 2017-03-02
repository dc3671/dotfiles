# Path to your oh-my-zsh installation.
export ZSH=/home/dash/.oh-my-zsh

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

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git history-substring-search tmux)

# User configuration

export PYTHON_HOME="/usr/lib/python2.7:/usr/lib64/python2.7:/usr/include/python2.7"
export GCC_HOME="/usr/lib/gcc/x86_64-redhat-linux/4.9.2"
export LKP_SRC="/home/dash/Project/lkp-tests"
export TEXHOME="/usr/share/texmf-dist"
export NPM_CONFIG_PREFIX="/home/dash/.npm-global"
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk"

export LC_ALL="en_US.utf8"

export PATH="/bin:/usr/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/home/dash/.local/bin:/home/dash/bin"
export PATH="$PATH:/usr/share/fonts"
export PATH="$PATH:$PYTHON_HOME"
export PATH="$PATH:$GCC_HOME/include/"
export PATH="$PATH:$LKP_SRC/bin"
export PATH="$TEXHOME:$PATH"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
export PATH="$JAVA_HOME/bin:$PATH"

export GIT_SSL_NO_VERIFY=1
export TERM="xterm-256color"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

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
alias npm='cnpm'
alias sa="sudo apt-get"


alias fq='~/xx-net.sh'
#alias understand='sudo /opt/scitools/bin/linux64/understand'[]
#alias clearlkp='rm /tmp/init*sult;'
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

# -------------------------------------------------------------------
# Git
# -------------------------------------------------------------------
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
alias gf='git reflog'


# -------------------------------------------------------------------
# SSH Server
# -------------------------------------------------------------------
