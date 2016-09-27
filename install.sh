#!/usr/bin/sh

# vim
curl https://j.mp/spf13-vim3 -L > spf13-vim.sh && sh spf13-vim.sh
ln -s $PWD/.vimrc.local ~/.vimrc.local
ln -s $PWD/.vimrc.before.local ~/.vimrc.before.local
ln -s $PWD/.vimrc.bundles.local ~/.vimrc.bundles.local

# tmux
mv ~/.tmux.conf ~/.tmux.conf.bak
ln -s $PWD/.tmux.conf ~/.tmux.conf

# zsh
mv ~/.zshrc ~/.zshrc.bak
ln -s $PWD/.zshrc ~/.zshrc

# eslint
mv ~/.eslintrc.json ~/.eslintrc.json.bak
ln -s $PWD/.eslintrc.json ~/.eslintrc.json

# ternjs
mv ~/.tern-config ~/.tern-config.bak
ln -s $PWD/.tern-config ~/.tern-config
