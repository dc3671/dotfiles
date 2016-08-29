#!/usr/bin/sh
curl https://j.mp/spf13-vim3 -L

rm ~/.vimrc.local
rm ~/.vimrc.before.local
rm ~/.vimrc.bundles.local
ln -s ~/.vimrc.local $PWD/.vimrc.local
ln -s ~/.vimrc.before.local $PWD/.vimrc.before.local
ln -s ~/.vimrc.bundles.local $PWD/.vimrc.bundles.local

mv ~/.tmux.conf ~/.tmux.conf.bak
ln -s ~/.tmux.conf $PWD/.tmux.conf

mv ~/.zshrc ~/.zshrc.bak
ln -s ~/.zshrc $PWD/.zshrc
































