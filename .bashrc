export OSH="$HOME/.oh-my-bash"
OSH_THEME="pzq"

completions=(git composer pip)
aliases=(general)
plugins=(git bashmarks)

[ -f "$OSH"/oh-my-bash.sh ] && source "$OSH"/oh-my-bash.sh
export _ble_contrib_fzf_base=~/.local/share/nvim/lazy/fzf
[ -f ~/ble.sh/out/ble.sh ] && source -- ~/ble.sh/out/ble.sh

__dotfiles="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
source "$__dotfiles/shell/common.sh"
unalias cp 2>/dev/null   # omb general aliases: cp -iv

# agent socket juggling spawns ssh-add/ssh-agent + rewrites ~/.ssh/auth_sock.
# my shells only; no agent churn per rsync connection.
_my_shell && source "$__dotfiles/scripts/ssh-reconnect.sh"
unset __dotfiles
