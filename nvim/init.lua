-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

-- Check for clipboard support and required executables
if vim.fn.has('clipboard') == 1 and
    (vim.fn.executable('pbcopy') == 1 or
        vim.fn.executable('xclip') == 1 or
        vim.fn.executable('xsel') == 1) then
    vim.opt.clipboard:append({ "unnamed", "unnamedplus" })
end

-- Set thesaurus on Unix systems
if vim.fn.has('unix') == 1 then
    vim.opt.thesaurus:append("/usr/share/dict/words")
end

function DeleteEmptyBuffers()
    local empty = {}
    for i = 1, vim.fn.bufnr('$') do
        if vim.fn.bufexists(i) == 1 and
            (vim.fn.bufname(i) == '' or vim.fn.filereadable(vim.fn.bufname(i)) == 0) then
            table.insert(empty, i)
        end
    end
    if #empty > 0 then
        vim.cmd('bdelete ' .. table.concat(empty, ' '))
    end
end

DeleteEmptyBuffers()

require("core.init")
