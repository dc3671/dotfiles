" Environment {

  " Identify platform {
    silent function! OSX()
      return has('macunix')
    endfunction
    silent function! LINUX()
      return has('unix') && !has('macunix') && !has('win32unix')
    endfunction
    silent function! WINDOWS()
      return  (has('win32') || has('win64'))
    endfunction
  " }

  " Basics {
    set nocompatible    " Must be first line
    if !WINDOWS()
      set shell=/bin/sh
    endif
  " }
  "
  " Use bundles config {
    if filereadable(expand("~/.vimrc.bundles"))
      source ~/.vimrc.bundles
    endif
  " }

" }


" General {

  " Basic {
    set mouse=a         " Automatically enable mouse usage
    set mousehide         " Hide the mouse cursor while typing
    "set autowrite             " Automatically write a file when leaving a modified buffer
    set shortmess+=filmnrxoOtT      " Abbrev. of messages (avoids 'hit enter')
    set viewoptions=cursor,folds,slash,unix " Better Unix / Windows compatibility
    set virtualedit=onemore       " Allow for cursor beyond last character
    set history=1000          " Store a ton of history (default is 20)
    set nospell             " Spell checking off
    set hidden              " Allow buffer switching without saving
    set iskeyword-=.          " '.' is an end of word designator
    set iskeyword-=#          " '#' is an end of word designator
    set iskeyword-=-          " '-' is an end of word designator
    filetype plugin indent on   " Automatically detect file types.
    " for better cursor move speed
    set regexpengine=1
    set synmaxcol=200
  " }

  " Encoding {
    scriptencoding utf-8
    set encoding=utf-8
    set fileencodings=utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1
    set termencoding=utf-8
  " }

  " Key (re)Mappings {
    " The default leader is '\', but many people prefer ',' as it's in a standard
    " location. To override this behavior and set it back to '\' (or any other
    " character) add the following to your .vimrc.before.local file:
    " let g:cfg_leader='\'
    if !exists('g:cfg_leader')
      let mapleader = ','
    else
      let mapleader=g:leader
    endif
    if !exists('g:cfg_localleader')
      let maplocalleader = '_'
    else
      let maplocalleader=g:localleader
    endif

    " Easier moving in tabs and windows
    " The lines conflict with the default digraph mapping of <C-K>
    " If you prefer that functionality, add the following to your
    " .vimrc.before.local file:
    "let g:cfg_no_easyWindows = 1
    if !exists('g:cfg_no_easyWindows')
      noremap <C-J> <C-W>j
      noremap <C-K> <C-W>k
      noremap <C-L> <C-W>l
      noremap <C-H> <C-W>h
    endif

    " Wrapped lines goes down/up to next row, rather than next line in file.
    noremap j gj
    noremap k gk

    " End/Start of line motion keys act relative to row/wrap width in the
    " presence of `:set wrap`, and relative to line for `:set nowrap`.
    " Default vim behaviour is to act relative to text line in both cases
    " If you prefer the default behaviour, add the following to your
    " .vimrc.before.local file:
    "   let g:cfg_no_wrapRelMotion = 1
    if !exists('g:cfg_no_wrapRelMotion')
      " Same for 0, home, end, etc
      function! WrapRelativeMotion(key, ...)
        let vis_sel=""
        if a:0
          let vis_sel="gv"
        endif
        if &wrap
          execute "normal!" vis_sel . "g" . a:key
        else
          execute "normal!" vis_sel . a:key
        endif
      endfunction

      " Map g* keys in Normal, Operator-pending, and Visual+select
      noremap $ :call WrapRelativeMotion("$")<CR>
      noremap <End> :call WrapRelativeMotion("$")<CR>
      noremap 0 :call WrapRelativeMotion("0")<CR>
      noremap <Home> :call WrapRelativeMotion("0")<CR>
      noremap ^ :call WrapRelativeMotion("^")<CR>
      " Overwrite the operator pending $/<End> mappings from above
      " to force inclusive motion with :execute normal!
      onoremap $ v:call WrapRelativeMotion("$")<CR>
      onoremap <End> v:call WrapRelativeMotion("$")<CR>
      " Overwrite the Visual+select mode mappings from above
      " to ensure the correct vis_sel flag is passed to function
      vnoremap $ :<C-U>call WrapRelativeMotion("$", 1)<CR>
      vnoremap <End> :<C-U>call WrapRelativeMotion("$", 1)<CR>
      vnoremap 0 :<C-U>call WrapRelativeMotion("0", 1)<CR>
      vnoremap <Home> :<C-U>call WrapRelativeMotion("0", 1)<CR>
      vnoremap ^ :<C-U>call WrapRelativeMotion("^", 1)<CR>
    endif

    " Stupid shift key fixes
    if !exists('g:cfg_no_keyfixes')
      if has("user_commands")
        command! -bang -nargs=* -complete=file E e<bang> <args>
        command! -bang -nargs=* -complete=file W w<bang> <args>
        command! -bang -nargs=* -complete=file Wq wq<bang> <args>
        command! -bang -nargs=* -complete=file WQ wq<bang> <args>
        command! -bang Wa wa<bang>
        command! -bang WA wa<bang>
        command! -bang Q q<bang>
        command! -bang QA qa<bang>
        command! -bang Qa qa<bang>
      endif

      cmap Tabe tabe
    endif

    " replace-paste yanked text in vim without yanking the deleted lines
    vnoremap p "_dP
    " Yank from the cursor to the end of the line, to be consistent with C and D.
    nnoremap Y y$

    " Code folding options
    nmap <leader>f0 :set foldlevel=0<CR>
    nmap <leader>f1 :set foldlevel=1<CR>
    nmap <leader>f2 :set foldlevel=2<CR>
    nmap <leader>f3 :set foldlevel=3<CR>
    nmap <leader>f4 :set foldlevel=4<CR>
    nmap <leader>f5 :set foldlevel=5<CR>
    nmap <leader>f6 :set foldlevel=6<CR>
    nmap <leader>f7 :set foldlevel=7<CR>
    nmap <leader>f8 :set foldlevel=8<CR>
    nmap <leader>f9 :set foldlevel=9<CR>

    " Most prefer to toggle search highlighting rather than clear the current
    " search results. To clear search highlighting rather than toggle it on
    " and off, add the following to your .vimrc.before.local file:
    "   let g:cfg_clear_search_highlight = 1
    if exists('g:cfg_clear_search_highlight')
      nmap <silent> <leader>/ :nohlsearch<CR>
    else
      nmap <silent> <leader>/ :set invhlsearch<CR>
    endif

    " Find merge conflict markers
    map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

    " Shortcuts
    " Change Working Directory to that of the current file
    cmap cwd lcd %:p:h
    cmap cd. lcd %:p:h

    " Visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv

    " Allow using the repeat operator with a visual selection (!)
    " http://stackoverflow.com/a/8064607/127816
    vnoremap . :normal .<CR>

    " For when you forget to sudo.. Really Write the file.
    "cmap w!! w !sudo tee % >/dev/null
    cmap w!! %!sudo tee > /dev/null %

    " Some helpers to edit mode
    cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
    map <leader>ew :e %%
    map <leader>es :sp %%
    map <leader>ev :vsp %%
    map <leader>et :tabe %%

    " Adjust viewports to the same size
    map <Leader>= <C-w>=

    " Map <Leader>ff to display all lines with keyword under cursor
    " and ask which one to jump to
    nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

    " Easier horizontal scrolling
    map zl zL
    map zh zH

    " Easier formatting
    nnoremap <silent> <leader>q gwip

    " Use 'm/M' to move among buffers
    noremap m :bn<CR>
    noremap M :bp<CR>

    " toggle between two buffers
    nnoremap t <C-^>

    " Quick move in insert mode
    inoremap <C-o> <Esc>o
    inoremap <C-a> <Home>
    inoremap <C-e> <End>
    inoremap <A-h> <Left>
    inoremap <A-j> <Down>
    inoremap <A-k> <Up>
    inoremap <A-l> <Right>
    inoremap <C-d> <Backspace>

    " Go to home and end using capitalized directions
    noremap H 0
    noremap L $

    " select all
    noremap <Leader>sa ggVG
  " }

" }

" Vim UI {

  " Basic {
    syntax on           " Syntax highlighting
    let g:edge_style = 'aura'
    let g:edge_enable_italic = 0
    let g:edge_disable_italic_comment = 1
    colorscheme edge
    set tabpagemax=15         " Only show 15 tabs
    set showmode          " Display the current mode
    set cursorline          " Highlight current line
    highlight clear SignColumn    " SignColumn should match background
    highlight clear LineNr      " Current line number row will have same background color in relative mode
    "highlight clear CursorLineNr  " Remove highlight color from current line number

    if has('cmdline_info')
      set ruler           " Show the ruler
      set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
      set showcmd         " Show partial commands in status line and Selected characters/lines in visual mode
    endif

    if has('statusline')
      set laststatus=2
      " Broken down into easily includeable segments
      set statusline=%<%f\           " Filename
      set statusline+=%w%h%m%r         " Options
      if !exists('g:override_bundles')
        set statusline+=%{fugitive#statusline()} " Git Hotness
      endif
      set statusline+=\ [%{&ff}/%Y]      " Filetype
      set statusline+=\ [%{getcwd()}]      " Current dir
      set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
    endif

    set backspace=indent,eol,start  " Backspace for dummies
    set linespace=0         " No extra spaces between rows
    set number            " Line numbers on
    set showmatch           " Show matching brackets/parenthesis
    set incsearch           " Find as you type search
    set hlsearch          " Highlight search terms
    set winminheight=0        " Windows can be 0 line high
    set ignorecase          " Case insensitive search
    set smartcase           " Case sensitive when uc present
    set wildmenu          " Show list instead of just completing
    set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
    set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
    set scrolljump=5        " Lines to scroll when cursor leaves screen
    set scrolloff=3         " Minimum lines to keep above and below cursor
    set foldenable          " Auto fold code
    set foldmethod=indent       " set foldmethod
    set foldlevelstart=99       " default not folding
    set list
    set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
    set nomodeline
    " for transparent probelm with konsole
    hi Normal  ctermfg=252 ctermbg=none
  " }

  " Rainbow {
    if isdirectory(expand("~/.vim/bundle/rainbow/"))
      let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
    endif
  " }

  " indent_guides {
    if isdirectory(expand("~/.vim/bundle/vim-indent-guides/"))
      let g:indent_guides_enable_on_vim_startup = 1
      let g:indent_guides_auto_colors = 0
      let g:indent_guides_guide_size = 2
      let g:indent_guides_start_level = 1
      autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#353535 ctermbg=240
      autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#3f3f3f ctermbg=240
    endif
  " }

  " vim-airline {
    if isdirectory(expand("~/.vim/bundle/vim-airline"))
      " Set configuration options for the statusline plugin vim-airline.
      " Use the powerline theme and optionally enable powerline symbols.
      " To use the symbols , , , , , , and .in the statusline
      " segments add the following to your .vimrc.before.local file:
      let g:airline_powerline_fonts=1
      " If the previous symbols do not render for you then install a
      " powerline enabled font.

      " See `:echo g:airline_theme_map` for some more choices
      " Default in terminal vim is 'dark'
      let g:airline#extensions#tabline#enabled = 0  " too slow
      let g:airline#extensions#tabline#ctrlspace_show_tab_nr = 1
      let g:airline#extensions#ale#enabled = 1
      let g:airline#extensions#tmuxline#enabled = 0
      let g:airline#extensions#ycm#enabled = 1
      if isdirectory(expand("~/.vim/bundle/vim-airline-themes/"))
        let g:airline_theme = 'edge'
        if !exists('g:airline_theme')
          let g:airline_theme = 'solarized'
        endif
        if exists('g:airline_powerline_fonts')
          " Use the default set of separators with a few customizations
          let g:airline_left_sep=''
          let g:airline_right_sep=''
        endif
      endif
    endif
  " }

  " emoji related {
    "if emoji#available()
      "let g:gitgutter_sign_added = emoji#for('small_blue_diamond')
      "let g:gitgutter_sign_modified = emoji#for('small_orange_diamond')
      "let g:gitgutter_sign_removed = emoji#for('small_red_triangle')
      "let g:gitgutter_sign_modified_removed = emoji#for('collision')
      "set completefunc=emoji#complete
    "endif
  " }

" }

" Management {

  " Basic {
    if has('clipboard')
      " use `:xrestore` to reload register
      if has('unnamedplus')  " When possible use + register for copy-paste
        set clipboard=unnamed,unnamedplus
      else     " On mac and Windows, use * register for copy-paste
        set clipboard=unnamed
      endif
    endif
    " Instead of reverting the cursor to the last position in the buffer, we
    " set it to the first line when editing a git commit message
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
    " Most prefer to automatically switch to the current file directory when
    " a new buffer is opened; to prevent this behavior, add the following to
    " your .vimrc.before.local file:
    let g:cfg_no_autochdir = 1
    if !exists('g:cfg_no_autochdir')
      " Always switch to the current file directory
      autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
    endif
  " }

  " NerdTree {
    if isdirectory(expand("~/.vim/bundle/nerdtree"))
      "map <C-e> <plug>NERDTreeTabsToggle<CR>
      "map <leader>e :NERDTreeFind<CR>
      "nmap <leader>nt :NERDTreeFind<CR>

      let NERDTreeShowBookmarks=1
      let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
      let NERDTreeChDirMode=0
      let NERDTreeQuitOnOpen=1
      let NERDTreeMouseMode=2
      let NERDTreeShowHidden=1
      let NERDTreeKeepTreeInNewTab=1
      let g:nerdtree_tabs_open_on_gui_startup=0
    endif
  " }
  " Fern.vim {
    if isdirectory(expand("~/.vim/bundle/fern.vim"))
      let g:fern#disable_default_mappings = 1

      nnoremap <silent> <C-e> :Fern . -drawer -reveal=% -toggle -width=35<CR>

      function! FernInit() abort
        nmap <buffer><expr>
              \ <Plug>(fern-my-open-expand-collapse)
              \ fern#smart#leaf(
              \   "\<Plug>(fern-action-open:select)",
              \   "\<Plug>(fern-action-expand)",
              \   "\<Plug>(fern-action-collapse)",
              \ )
        nmap <buffer> <CR> <Plug>(fern-my-open-expand-collapse)
        nmap <buffer> <2-LeftMouse> <Plug>(fern-my-open-expand-collapse)
        nmap <buffer> n <Plug>(fern-action-new-path)
        nmap <buffer> d <Plug>(fern-action-remove)
        nmap <buffer> m <Plug>(fern-action-move)
        nmap <buffer> M <Plug>(fern-action-rename)
        nmap <buffer> h <Plug>(fern-action-hidden-toggle)
        nmap <buffer> r <Plug>(fern-action-reload)
        nmap <buffer> K <Plug>(fern-action-mark-toggle)
        nmap <buffer> b <Plug>(fern-action-open:split)
        nmap <buffer> v <Plug>(fern-action-open:vsplit)
        nmap <buffer> t <Plug>(fern-action-open:tabedit)
        nmap <buffer><nowait> < <Plug>(fern-action-leave)
        nmap <buffer><nowait> > <Plug>(fern-action-enter)
      endfunction

      augroup FernGroup
        autocmd!
        autocmd FileType fern call FernInit()
      augroup END
    endif
  " }

  " vim-bbye {
    if isdirectory(expand("~/.vim/bundle/vim-bbye/"))
      nnoremap qq :Bwipeout<cr>
    endif
  " }

  " vim-ctrlspace {
    if isdirectory(expand("~/.vim/bundle/vim-ctrlspace"))
      set showtabline=0
      let g:CtrlSpaceLoadLastWorkspaceOnStart = 1
      let g:CtrlSpaceSaveWorkspaceOnSwitch = 1
      let g:CtrlSpaceSaveWorkspaceOnExit = 1
      let g:CtrlSpaceUseUnicode = 0
      let g:CtrlSpaceSymbols = { "CTab": "CTAB", "Tabs": "TABS" }
      if executable("ag")
        let g:CtrlSpaceGlobCommand = 'ag -l --nocolor -g ""'
      endif
    endif
  " }

  " Fugitive {
    if isdirectory(expand("~/.vim/bundle/vim-fugitive/"))
      nnoremap <silent> <leader>gs :Gstatus<CR>
      nnoremap <silent> <leader>gd :Gdiff<CR>
      nnoremap <silent> <leader>gc :Gcommit<CR>
      nnoremap <silent> <leader>gb :Gblame<CR>
      nnoremap <silent> <leader>gl :Glog<CR>
      nnoremap <silent> <leader>gp :Git push<CR>
      nnoremap <silent> <leader>gr :Gread<CR>
      nnoremap <silent> <leader>gw :Gwrite<CR>
      nnoremap <silent> <leader>ge :Gedit<CR>
      " Mnemonic _i_nteractive
      nnoremap <silent> <leader>ga :Git add -p %<CR>
      nnoremap <silent> <leader>gg :SignifyToggle<CR>
    endif
  "}

  " git-blame {
    if isdirectory(expand("~/.vim/bundle/git-blame.vim/"))
      nnoremap <Leader><leader>b :<C-u>call gitblame#echo()<CR>
    endif
  "}

  " UndoTree {
    set backup          " Backups are nice ...
    set undofile        " So is persistent undo ...
    set undolevels=1000     " Maximum number of changes that can be undone
    set undoreload=10000    " Maximum number lines to save for undo on a buffer reload

    if isdirectory(expand("~/.vim/bundle/undotree/"))
      nnoremap <Leader>u :UndotreeToggle<CR>
      " If undotree is opened, it is likely one wants to interact with it.
      let g:undotree_SetFocusWhenToggle=1
    endif
  " }

" }

" Editting {

  " Basic {
    set wrap            " Do wrap long lines
    set autoindent          " Indent at the same level of the previous line
    set shiftwidth=4        " Use indents of 4 spaces
    set expandtab           " Tabs are spaces, not tabs
    set tabstop=4           " An indentation every four columns
    set softtabstop=4         " Let backspace delete indent
    set nojoinspaces        " Prevents inserting two spaces after punctuation on a join (J)
    set splitright          " Puts new vsplit windows to the right of the current
    set splitbelow          " Puts new split windows to the bottom of the current
    set matchpairs+=<:>       " Match, to be used with %
    set pastetoggle=<F12>       " pastetoggle (sane indentation on pastes)
    autocmd FileType cpp set syntax=cpp.doxygen
    "autocmd FileType go autocmd BufWritePre <buffer> Fmt
    "autocmd BufNewFile,BufRead *.vue set filetype=vue.html.javascript.css
    "autocmd BufNewFile,BufRead *.js set filetype=javascript.jsx
    autocmd BufNewFile,BufRead *.tsx set filetype=typescript.tsx
    autocmd BufNewFile,BufRead *.jsx set filetype=javascript.jsx
    autocmd BufNewFile,BufRead *.ejs set filetype=html
    autocmd FileType javascript,typescript,vue,html,css,json,vim setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
    "autocmd FileType vue syntax sync fromstart

    " Restore cursor to file position in previous editing session
    "let g:cfg_no_restore_cursor = 1
    if !exists('g:cfg_no_restore_cursor')
      autocmd BufLeave,BufWinLeave * silent! mkview
      autocmd BufReadPost * silent! loadview
    endif
  " }

  " Linter & Formatter, use Ale {
    if isdirectory(expand("~/.vim/bundle/ale/"))
      noremap <leader><leader>f :ALEFix<CR>
      noremap <leader>F :ALEFix<CR>
      noremap ]a :ALENextWrap<CR>
      noremap [a :ALEPreviousWrap<CR>
      noremap ]A :ALELast
      noremap [A :ALEFirst
      " let g:ale_lint_on_text_changed = 'never'
      let g:ale_sign_error = '>>'
      let g:ale_sign_warning = '??'
      let g:ale_echo_msg_format = '%s [%severity%%/code%]'
      let g:ale_set_highlights = 0
      let g:ale_c_parse_compile_commands=1
      let g:ale_linters_explicit=1
      let g:ale_linters = {
        \'javascript': ['eslint'],
        \'typescript': ['eslint'],
        \'python': ['pylint'],
        \'vue': ['prettier'],
        \'cpp': ['clangtidy', 'cpplint'],
      \}
      let g:ale_cpp_clang_options = '-std=c++1z -Wall'
      let g:ale_fixers = {
        \'*': ['trim_whitespace'],
        \'javascript': ['eslint'],
        \'typescript': ['eslint'],
        \'python': ['black', 'isort'],
        \'vue': ['prettier'],
        \'cpp': ['clang-format'],
        \'sh': ['shfmt'],
      \}
      "let g:ale_c_clangformat_options = '-style="{
        "\BasedOnStyle: google,
        "\IndentWidth: 4,
        "\AccessModifierOffset: -4,
        "\AlignAfterOpenBracket: AlwaysBreak,
        "\BinPackArguments: false,
        "\BinPackParameters: false,
        "\IncludeBlocks: Regroup}"'
      let g:ale_c_clangformat_options = '-style=file'
    endif
    let g:vue_disable_pre_processors=1
    let g:vim_jsx_pretty_enable_jsx_highlight = 1
    let g:vim_jsx_pretty_colorful_config = 1
  " }

  " AutoCloseTag {
    " Make it so AutoCloseTag works for xml and xhtml files as well
    "au FileType xhtml,xml ru ftplugin/html/autoclosetag.vim
    "nmap <Leader>ac <Plug>ToggleAutoCloseMappings
    if isdirectory(expand("~/.vim/bundle/vim-closetag"))
      let g:closetag_filetypes = 'html,xhtml,phtml,vue,php,javascript,typescript'
      let g:closetag_xhtml_filetypes = 'html,xhtml,phtml,vue,php,javascript,typescript'
    endif
  " }

  " Tabularize, align multi lines along a symbol {
    if isdirectory(expand("~/.vim/bundle/tabular"))
      nmap <Leader>a& :Tabularize /&<CR>
      vmap <Leader>a& :Tabularize /&<CR>
      nmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
      vmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
      nmap <Leader>a=> :Tabularize /=><CR>
      vmap <Leader>a=> :Tabularize /=><CR>
      nmap <Leader>a: :Tabularize /:<CR>
      vmap <Leader>a: :Tabularize /:<CR>
      nmap <Leader>a:: :Tabularize /:\zs<CR>
      vmap <Leader>a:: :Tabularize /:\zs<CR>
      nmap <Leader>a, :Tabularize /,<CR>
      vmap <Leader>a, :Tabularize /,<CR>
      nmap <Leader>a,, :Tabularize /,\zs<CR>
      vmap <Leader>a,, :Tabularize /,\zs<CR>
      nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
      vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
    endif
  " }

  " MatchTagAlways {
    if isdirectory(expand("~/.vim/bundle/MatchTagAlways"))
      let g:mta_filetypes = { 'html' : 1, 'xhtml' : 1, 'xml' : 1, 'jinja' : 1, 'php' : 1, 'vue' : 1 }
    endif
  " }

" }

" Selecting {

  " Multiple Cursors {
    if isdirectory(expand("~/.vim/bundle/vim-multiple-cursors"))
      "let g:multi_cursor_next_key='<C-n>'
      "let g:multi_cursor_prev_key='<C-p>'
      let g:multi_cursor_skip_key='<C-l>'
    endif
  " }

  " wildfire {
    if isdirectory(expand("~/.vim/bundle/wildfire.vim"))
      " This selects the next closest text object.
      map <SPACE> <Plug>(wildfire-fuel)
      " This selects the previous closest text object. (comflict with system shortcut)
      "vmap <C-SPACE> <Plug>(wildfire-water)
      nmap <leader><leader>s <plug>(wildfire-quick-select)
      let g:wildfire_objects = {
        \ "*" : ["i'", 'i"', "i)", "i]", "i}", "ip"],
        \ "html,xml" : ["at"],
      \}
    endif
  " }

  " vim-textobj-user, to quickly select(v)/delete(d) specific text pattern {
    " 'kana/vim-textobj-indent'
    " ai/ii for same or more indent, aI/iI for same
    " 'beloglazov/vim-textobj-quotes'
    " iq/aq for single ('), double ("), or back (`) quotes
    " 'Julian/vim-textobj-brace'
    " ij/aj for [], {}, or ().
    " 'Chun-Yang/vim-textobj-chunk'
    " ic/ac for a whole function/space, more useful than ai.
    " 'whatyouhide/vim-textobj-xmlattr'
    " ix works with the inner attribute, with no surrounding whitespace. ax works like aw does: it includes the whitespace before the attribute.
    " 'jceb/vim-textobj-uri'
    " iu/au for uri without/with trailing whitespaces
  " }

" }

" Searching {

  " TagBar & Ctags {
    if isdirectory(expand("~/.vim/bundle/tagbar"))
      nmap <F8> :TagbarToggle<CR>
      set tags=./tags;/,~/.vimtags
      " for javascript support, `npm i -g jsctags`
      " for typescript support, `npm install --global git+https://github.com/Perlence/tstags.git`
      let g:vim_tags_use_language_field = 1
      let g:tagbar_type_typescript = {
        \ 'ctagsbin' : 'tstags',
        \ 'ctagsargs' : '-f-',
        \ 'kinds': [
          \ 'e:enums:0:1',
          \ 'f:function:0:1',
          \ 't:typealias:0:1',
          \ 'M:Module:0:1',
          \ 'I:import:0:1',
          \ 'i:interface:0:1',
          \ 'C:class:0:1',
          \ 'm:method:0:1',
          \ 'p:property:0:1',
          \ 'v:variable:0:1',
          \ 'c:const:0:1',
        \ ],
        \ 'sort' : 0
      \ }
      " Make tags placed in .git/tags file available in all levels of a repository
      let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
      if gitroot != ''
        let &tags = &tags . ',' . gitroot . '/.git/tags'
      endif
    endif
  " }

  " fzf, alternate to ctrlp {
    if isdirectory(expand("~/.vim/bundle/fzf.vim/"))
      function! s:find_files()
        let git_dir = system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
        if git_dir != ''
          execute 'GFiles' git_dir
        else
          execute 'Files'
        endif
      endfunction
      command! ProjectFiles execute s:find_files()
      nnoremap <silent> <C-p> :ProjectFiles<CR>
      nnoremap <silent> <C-t> :Tags<CR>
      nnoremap <silent> <C-b> :Buffers<CR>
      nnoremap <leader><leader>/ :Ag<space>
    endif
  " }

  " CtrlSF {
    if isdirectory(expand("~/.vim/bundle/ctrlsf.vim/"))
      nmap   <C-F>f <Plug>CtrlSFPrompt
      vmap   <C-F>f <Plug>CtrlSFVwordPath
      vmap   <C-F>F <Plug>CtrlSFVwordExec
      nmap   <C-F>n <Plug>CtrlSFCwordPath
      nmap   <C-F>p <Plug>CtrlSFPwordPath
      nnoremap <C-F>o :CtrlSFOpen<CR>
      nnoremap <C-F>t :CtrlSFToggle<CR>
      inoremap <C-F>t <Esc>:CtrlSFToggle<CR>
    endif
  " }

" }

" Completer {

  " YouCompleteMe {
    if count(g:cfg_bundle_groups, 'youcompleteme')
      let g:acp_enableAtStartup = 0

      " enable completion from tags
      let g:ycm_collect_identifiers_from_tags_files = 1
      let g:ycm_python_binary_path = 'python'
      let g:ycm_clangd_args=['--header-insertion=never']

      " remap Ultisnips for compatibility for YCM
      let g:UltiSnipsExpandTrigger = '<C-v>'
      let g:UltiSnipsJumpForwardTrigger = '<C-j>'
      let g:UltiSnipsJumpBackwardTrigger = '<C-k>'
      let g:UltiSnipsSnippetsDir = '~/.vim/bundle/vim-snippet/Ultisnips'

      " not ask about loading config files
      let g:ycm_confirm_extra_conf = 0
      let g:ycm_autoclose_preview_window_after_insertion = 1
      let g:ycm_auto_hover = ''
      let g:ycm_complete_in_strings = 1
      let g:ycm_complete_in_comments = 1
      let g:ycm_key_list_select_completion = ['<TAB>', '<Down>']
      let g:ycm_key_list_previous_completion = ['<S-TAB>', '<Up>']
      let g:ycm_show_diagnostics_ui = 1
      let g:ycm_error_symbol = '>>'
      let g:ycm_warning_symbol = '??'
      let g:ycm_enable_diagnostic_highlighting = 0
      let g:ycm_semantic_triggers =  {
        \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{3}'],
        \ 'cs,lua,javascript,jsx,typescript,tsx,vue': ['re!\w{3}'],
        \ }
      let g:ycm_filetype_blacklist = {
        \ 'tagbar' : 1,
        \ 'qf' : 1,
        \ 'notes' : 1,
        \ 'markdown' : 1,
        \ 'unite' : 1,
        \ 'text' : 1,
        \ 'vimwiki' : 1,
        \ 'pandoc' : 1,
        \ 'infolog' : 1,
        \ 'json' : 1,
        \ 'out' : 1,
        \ 'gitcommit' : 1,
        \ }
      let g:ycm_language_server = [ {
        \ 'name': 'vue',
        \ 'filetypes': [ 'vue' ],
        \ 'cmdline': [ 'vls' ]
        \ } ]

      nnoremap <leader>D :YcmCompleter GoTo<CR>
      nnoremap <leader>T :YcmCompleter GetType<CR>
      nmap <leader>K <plug>(YCMHover)
      nnoremap <leader>R :YcmCompleter RefactorRename<space>
    endif
  " }

" }

" Languages {

  " MarkDown {
    let g:vim_markdown_conceal = 0
    let g:vim_markdown_conceal_code_blocks = 0
  " }

  " JSON {
    nmap <leader>jt <Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>
    let g:vim_json_syntax_conceal = 0
  " }

" }

" GUI Settings {

  " GVIM- (here instead of .gvimrc)
  if has('gui_running')
    set guioptions-=T       " Remove the toolbar
    set lines=40        " 40 lines of text instead of 24
    set guioptions=
    if OSX()
      set guifont=Droid\ Sans\ Mono\ for\ Powerline:h13
    endif
    if LINUX()
      set guifont=Droid\ Sans\ Mono\ for\ Powerline\ 10
    endif
    set linespace=2
  else
    if &term == 'xterm' || &term == 'screen'
      set t_Co=256      " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
    endif
  endif

" }

" Functions {

  " Initialize directories {
  function! InitializeDirectories()
    let parent = $HOME
    let prefix = 'vim'
    let dir_list = {
          \ 'backup': 'backupdir',
          \ 'views': 'viewdir',
          \ 'swap': 'directory' }
    let dir_list['undo'] = 'undodir'

    " To specify a different directory in which to place the vimbackup,
    " vimviews, vimundo, and vimswap files/directories, add the following to
    " your .vimrc.before.local file:
    "   let g:consolidated_directory = <full path to desired directory>
    "   eg: let g:consolidated_directory = $HOME . '/.vim/'
    if exists('g:consolidated_directory')
      let common_dir = g:consolidated_directory . prefix
    else
      let common_dir = parent . '/.' . prefix
    endif

    for [dirname, settingname] in items(dir_list)
      let directory = common_dir . dirname . '/'
      if exists("*mkdir")
        if !isdirectory(directory)
          call mkdir(directory)
        endif
      endif
      if !isdirectory(directory)
        echo "Warning: Unable to create backup directory: " . directory
        echo "Try: mkdir -p " . directory
      else
        let directory = substitute(directory, " ", "\\\\ ", "g")
        exec "set " . settingname . "=" . directory
      endif
    endfor
  endfunction
  call InitializeDirectories()
  " }

  " Initialize NERDTree as needed {
  function! NERDTreeInitAsNeeded()
    redir => bufoutput
    buffers!
    redir END
    let idx = stridx(bufoutput, "NERD_tree")
    if idx > -1
      NERDTreeMirror
      NERDTreeFind
      wincmd l
    endif
  endfunction
  " }

  " Shell command {
  function! s:RunShellCommand(cmdline)
    botright new

    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal nobuflisted
    setlocal noswapfile
    setlocal wrap
    setlocal filetype=shell
    setlocal syntax=shell

    call setline(1, a:cmdline)
    call setline(2, substitute(a:cmdline, '.', '=', 'g'))
    execute 'silent $read !' . escape(a:cmdline, '%#')
    setlocal nomodifiable
    1
  endfunction

  command! -complete=file -nargs=+ Shell call s:RunShellCommand(<q-args>)
  " e.g. Grep current file for <search_term>: Shell grep -Hn <search_term> %
  " }

  function! s:ExpandFilenameAndExecute(command, file)
    execute a:command . " " . expand(a:file, ":p")
  endfunction

  " for tmux to automatically set paste and nopaste mode at the time pasting (as
  " happens in VIM UI)
  function! WrapForTmux(s)
    if !exists('$TMUX')
      return a:s
    endif

    let tmux_start = "\<Esc>Ptmux;"
    let tmux_end = "\<Esc>\\"

    return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
  endfunction

  let &t_SI .= WrapForTmux("\<Esc>[?2004h")
  let &t_EI .= WrapForTmux("\<Esc>[?2004l")

  function! XTermPasteBegin()
    set pastetoggle=<Esc>[201~
    set paste
    return ""
  endfunction

  inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

" }

" Use local gvimrc if available and gui is running {
  if has('gui_running')
    if filereadable(expand("~/.gvimrc.local"))
      source ~/.gvimrc.local
    endif
  endif
" }
