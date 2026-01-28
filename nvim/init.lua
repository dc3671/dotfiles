-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

-- Clipboard setup
vim.opt.clipboard:append({ "unnamed", "unnamedplus" })

-- Delete empty buffers function
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

-- Load configuration
require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
