#!/bin/bash

# vim
mv ~/.vimrc.local ~/.vimrc.local.bak > /dev/null 2>&1
ln -s $PWD/.vimrc.local ~/.vimrc.local
ln -s $PWD/.vimrc.before.local ~/.vimrc.before.local
ln -s $PWD/.vimrc.bundles.local ~/.vimrc.bundles.local

# tmux
mv ~/.tmux.conf ~/.tmux.conf.bak >/dev/null 2>&1
ln -s $PWD/.tmux.conf ~/.tmux.conf

# zsh
mv ~/.zshrc ~/.zshrc.bak >/dev/null 2>&1
ln -s $PWD/.zshrc ~/.zshrc

# eslint
mv ~/.eslintrc.js ~/.eslintrc.js.bak >/dev/null 2>&1
ln -s $PWD/.eslintrc.js ~/.eslintrc.js

# ternjs
mv ~/.tern-config ~/.tern-config.bak >/dev/null 2>&1
ln -s $PWD/.tern-config ~/.tern-config

# pylint
mv ~/.pylintrc ~/.pylintrc.bak >/dev/null 2>&1
ln -s $PWD/.pylintrc ~/.pylintrc
