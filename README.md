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

* For tmux:

```
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

then open tmux and type `<Leader>+shift+i` to install other plugins

* For zsh, to change local user's default shell:

```
$ chsh -s /bin/zsh
```

then reopen terminal.

## Contact ##

[Dash Chen](https://github.com/dc3671) <chenzhh3671@gmail.com>
