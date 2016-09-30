# Dotfiles #

My dotfiles for:

* vim(with spf13-vim)
* tmux
* zsh(with oh-my-zsh)

## Install ##

* Make sure `vim`&`spf13-vim`, `tmux`, `zsh`&`oh-my-zsh` have been installed.

* Run `install.sh` to link the config file to `$HOME` directory.

* For vim:

```bash
$ vim +BundleInstall +BundleClean +q
```

* For `YouCompleteMe` plugin of vim:

```bash
$ cd ~/.vim/bundle/YouCompleteMe/
$ python install.py
```

* For `ternjs/tern_for_vim` plugin of vim:

```bash
$ cd ~/.vim/bundle/tern_for_vim/
$ npm install
```

* For tmux, then open tmux and type `<Leader>+shift+i` to install other plugins

```
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

* For zsh, to change local user's default shell, then reopen terminal.

```
$ chsh -s /bin/zsh
```

## Contact ##

[Dash Chen](https://github.com/dc3671) <chenzhh3671@gmail.com>
