#!/bin/bash
# Link dotfiles into $HOME and fetch shell/tmux frameworks. Idempotent: existing
# clones are kept, a real file in the way is moved to <file>.bkp.<epoch>.
#
#   ./install.sh                 # frameworks + links
#   ./install.sh --link-only     # links only, no network (home-env-migration)
#
# No chsh: LDAP accounts cannot change it; .bash_profile execs ~/zsh/bin/zsh.
# nvim/node/zsh/fzf binaries are manual per-arch installs (see shell/common.sh);
# nvim bootstraps lazy.nvim itself and pins plugins via nvim/lazy-lock.json.

set -u
DOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LINK_ONLY=0
for a in "$@"; do
    case $a in
        --link-only) LINK_ONLY=1 ;;
        *) echo "unknown option: $a" >&2; exit 2 ;;
    esac
done

msg() { printf '%b\n' "$1" >&2; }

# link SRC DST: DST -> $DOT/SRC
link() {
    local src=$DOT/$1 dst=$2
    [ "$(readlink "$dst")" = "$src" ] && return
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "$dst.bkp.$(date +%s)" && msg "[link] backed up $dst"
    fi
    ln -sfn "$src" "$dst" && msg "[link] $dst -> $src"
}

# clone URL DIR [git clone args...]: skip when DIR exists
clone() {
    local url=$1 dir=$2
    shift 2
    [ -d "$dir" ] && return
    git clone --depth=1 "$@" "$url" "$dir"
}

if [ $LINK_ONLY = 0 ]; then
    for p in git zsh tmux make; do
        command -v $p >/dev/null 2>&1 || msg "\33[31m[✘]\33[0m '$p' not found in PATH"
    done

    msg ">>> zsh: oh-my-zsh + plugins + p10k"
    clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
    clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

    msg ">>> bash: oh-my-bash + ble.sh"
    clone https://github.com/ohmybash/oh-my-bash.git ~/.oh-my-bash
    clone https://github.com/akinomyoga/ble.sh.git ~/ble.sh --recursive --shallow-submodules
    [ -f ~/ble.sh/out/ble.sh ] || make -C ~/ble.sh

    msg ">>> tmux: tpm + plugins"
    clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    clone https://github.com/tmux-plugins/tmux-sensible ~/.tmux/plugins/tmux-sensible
    clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/plugins/tmux-resurrect
fi

msg ">>> links"
for f in .zshrc .p10k.zsh .bashrc .bash_profile .blerc .inputrc .tmux.conf; do
    link "$f" "$HOME/$f"
done
mkdir -p ~/.config
link nvim ~/.config/nvim

msg "\33[32m[✔]\33[0m done; open a new shell to load it"
