# Dotfiles #

My dotfiles for:

* vim(with [spf13-vim](https://github.com/spf13/spf13-vim))
* tmux
* zsh(with [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh))

## Install ##

* Make sure `vim`, `tmux`, `zsh`&`oh-my-zsh`, `node`, `python` have been installed.

```bash
# install oh-my-zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
# change to /bin/zsh
chsh -s /bin/zsh
```

* Link config files to `$HOME` directory.

```bash
git clone https://github.com/dc3671/dotfiles.git
cd dotfiles
./link_config.sh
```

* Install required plugins for vim:

```bash
vim +BundleInstall +BundleClean +q
```

* Compile `YouCompleteMe` plugin:

```bash
cd ~/.vim/bundle/YouCompleteMe/
python install.py
```

* Compile `ternjs/tern_for_vim` plugin:

```bash
cd ~/.vim/bundle/tern_for_vim/
npm install
```

* [Optional] Install plugin manager for tmux, then open tmux and press `<C-x>+Shift+i`

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```


## Contact ##

[Dash Chen](https://github.com/dc3671) <chenzhh3671@gmail.com>
