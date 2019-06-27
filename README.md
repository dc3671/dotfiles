# Dotfiles #

My dotfiles for frontend-developer and python-user, including:

* vim(support vue files and python pylint)
* tmux
* zsh(with [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh))

## Install ##

Make sure `vim`, `tmux`, `zsh`, `git` have been installed.

```bash
git clone https://github.com/dc3671/dotfiles.git
cd dotfiles
./install.sh
```

## Advanced config for `YouCompleteMe` ##

Install [`YouCompleteMe`](https://github.com/Valloric/YouCompleteMe) plugin, require Vim 7.4.1578 with Python 2 or Python 3 support. Because `YouCompleteMe` contains many submodules and it will cost a lot of time, I just add basic `js` and `python` support of it. If you need more support such as Go, Java, and C, you may do as below:

```bash
cd ~/.vim/bundle/YouCompleteMe/
# for C# support
python install.py --cs-completer
# for Go support
python install.py --go-completer
# for Java support
python install.py --java-completer
```
reference: https://github.com/Valloric/YouCompleteMe#installation

## Key Mappings ##

**may already be depreciated**

### Tmux ###

`<leader>` key has been changed to ctrl+x
```tmux
set -g prefix C-x
```

resize window
```tmux
bind -r ^k resizep -U 10 # upward (prefix Ctrl+k)
bind -r ^j resizep -D 10 # downward (prefix Ctrl+j)
bind -r ^h resizep -L 10 # to the left (prefix Ctrl+h)
bind -r ^l resizep -R 10 # to the right (prefix Ctrl+l)
```

swap windows position
```tmux
# swap with the previous pane (prefix Ctrl+u)
bind ^u swapp -U
# swap with the next pane (prefix Ctrl+d)
bind ^d swapp -D
```

split window
```tmux
unbind '"'          # vertical split (prefix -)
bind - splitw -v
unbind %
bind | splitw -h    # horizontal split (prefix |)
```

reload config `prefix+r`
```tmux
bind r source-file ~/.tmux.conf \; display "Reloaded!"
```

### Vim ###

`<leader>` key has been changed to `,`
```vim
let mapleader = ','
```

edit or save&reload vim config without exit
```vim
let g:spf13_edit_config_mapping='<leader>ec'
let g:spf13_apply_config_mapping='<leader>sc'
```

easier moving in windows
```vim
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l
map <C-H> <C-W>h
```

delete current buffer
```vim
nnoremap qq :Bdelete<cr>
```

toggle search highlight
```vim
nmap <silent> <leader>/ :set invhlsearch<CR>
```

delete all trailing whitespaces
```vim
map <leader><space> :FixWhitespace<cr>
```

use 'm/M' to move among buffers
```vim
noremap m :bn<CR>
noremap M :bp<CR>
```

toggle between two buffers
```vim
nnoremap t <C-^>
```
quick move in insert mode
```vim
inoremap <C-o> <Esc>o
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <C-d> <DELETE>
```

Go to home and end using capitalized directions
```vim
noremap H 0
noremap L $
noremap Y y$
```

select all
```vim
noremap <Leader>sa ggVG
```

autoformat file
```vim
noremap <leader><leader>f :Autoformat<CR>
```

CtrlSF, a grep plugin like that in SublimeText
```vim
nmap     <C-F>f <Plug>CtrlSFPrompt
vmap     <C-F>f <Plug>CtrlSFVwordPath
vmap     <C-F>F <Plug>CtrlSFVwordExec
nmap     <C-F>n <Plug>CtrlSFCwordPath
nmap     <C-F>p <Plug>CtrlSFPwordPath
nnoremap <C-F>o :CtrlSFOpen<CR>
nnoremap <C-F>t :CtrlSFToggle<CR>
inoremap <C-F>t <Esc>:CtrlSFToggle<CR>
```

Nerdtree, show directory structures
```vim
map <C-e> <plug>NERDTreeTabsToggle<CR>
map <leader>e :NERDTreeFind<CR>
nmap <leader>nt :NERDTreeFind<CR>
```

fzf, search files/tags/text among project
```vim
nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <C-t> :Tags<CR>
nnoremap <leader><leader>/ :Ag<space>
```

more detailed mapping see `.vimrc` -> `Key Mapping` part

## Contact ##

Any problem is welcome in [issues](https://github.com/dc3671/dotfiles/issues)

[Dash Chen](https://github.com/dc3671) <chenzhh3671@gmail.com>
