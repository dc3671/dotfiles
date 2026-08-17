-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

-- Clipboard setup
vim.opt.clipboard:append({ "unnamed", "unnamedplus" })

-- Delete unnamed scratch buffers (never touches new files not yet written)
function DeleteEmptyBuffers()
    local empty = {}
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b)
            and vim.api.nvim_buf_get_name(b) == ''
            and not vim.bo[b].modified
            and vim.bo[b].buftype == ''
        then
            table.insert(empty, b)
        end
    end
    if #empty > 0 then
        vim.cmd('bdelete ' .. table.concat(empty, ' '))
    end
end

vim.api.nvim_create_user_command('BDEmpty', DeleteEmptyBuffers, {})

-- Load configuration
require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
