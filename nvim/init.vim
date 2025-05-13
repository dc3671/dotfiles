lua require('core.init')

if has('clipboard') && (executable('pbcopy') || executable('xclip') || executable('xsel'))
    set clipboard^=unnamed,unnamedplus
endif

if has('unix')
	set thesaurus+=/usr/share/dict/words
endif

autocmd FileType markdown setlocal spell

function! DeleteEmptyBuffers()
    let [i, n; empty] = [1, bufnr('$')]
    while i <= n
        if bufexists(i) && (bufname(i) == '' || !filereadable(bufname(i)))
            call add(empty, i)
        endif
        let i += 1
    endwhile
    if len(empty) > 0
        exe 'bdelete' join(empty)
    endif
endfunction
call DeleteEmptyBuffers()
