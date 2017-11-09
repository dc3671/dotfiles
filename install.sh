#!/bin/bash

msg() {
    printf '%b\n' "$1" >&2
}

success() {
    msg "\33[32m[✔]\33[0m ${1}${2}"
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
    exit 1
}

program_exists() {
    local ret='0'
    command -v $1 >/dev/null 2>&1 || { local ret='1'; }

    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi

    return 0
}

program_must_exist() {
    program_exists $1
    # throw error on non-zero return value
    if [ "$?" -ne 0 ]; then
        error "You must have '$1' installed to continue."
    fi
}

msg         ">>> Start checking basic requirement..."
program_must_exist "vim"
program_must_exist "git"
program_must_exist "zsh"
success     "Done."

# zsh
msg         ">>> Config zsh..."
msg         ">>> Install oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
msg         ">>> Change shell to zsh"
mv ~/.zshrc ~/.zshrc.bak >/dev/null 2>&1
ln -s $PWD/.zshrc ~/.zshrc
chsh -s /bin/zsh
success     "Done. You may need to re-login or reopen terminal to see the effect"

# vim
msg         ">>> Config vim..."
msg         ">>> Install Plug for vim plugins management..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim >/dev/null 2>&1
mv ~/.vimrc ~/.vimrc.bak > /dev/null 2>&1
mv ~/.vimrc.before ~/.vimrc.before.bak > /dev/null 2>&1
mv ~/.vimrc.bundles ~/.vimrc.bundles.bak > /dev/null 2>&1
ln -s $PWD/.vimrc ~/.vimrc
ln -s $PWD/.vimrc.before ~/.vimrc.before
ln -s $PWD/.vimrc.bundles ~/.vimrc.bundles
vim -u "$PWD/.vimrc.bundles" "+set nomore" "+PlugInstall!" "+PlugClean" "+qall"

# eslint
mv ~/.eslintrc.js ~/.eslintrc.js.bak >/dev/null 2>&1
ln -s $PWD/.eslintrc.js ~/.eslintrc.js

# ternjs
mv ~/.tern-config ~/.tern-config.bak >/dev/null 2>&1
ln -s $PWD/.tern-config ~/.tern-config

# pylint
mv ~/.pylintrc ~/.pylintrc.bak >/dev/null 2>&1
ln -s $PWD/.pylintrc ~/.pylintrc

success     "Done."

# tmux
msg         ">>> Config tmux..."
mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
mv ~/.tmux.conf ~/.tmux.conf.bak >/dev/null 2>&1
ln -s $PWD/.tmux.conf ~/.tmux.conf
success     "Done."

msg         "\nThanks for using my dotfiles."
msg         "© `date +%Y` https://github.com/dc3671/dotfiles"
