export ZSH=~/.oh-my-zsh
ZSH_THEME="powerlevel10k/powerlevel10k"

if [[ -r $HOME/.local/share/nvim/lazy/fzf ]]; then
  export FZF_BASE=$HOME/.local/share/nvim/lazy/fzf
fi

# Add wisely, as too many plugins slow down shell startup.
plugins=(git gitfast dirhistory tmux python pip zsh-autosuggestions zsh-syntax-highlighting fzf)

export PYTHONUSERBASE="intentionally-disabled"

# Before omz: its plugins probe PATH (fzf, rg, tmux) at load time.
source ${${(%):-%x}:A:h}/shell/common.sh

source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

unsetopt PROMPT_SP
setopt ignoreeof
source ${${(%):-%x}:A:h}/scripts/ssh-reconnect.sh
