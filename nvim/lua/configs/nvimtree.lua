local M = {}
function M.config()
    local function on_attach(bufnr)
        local api = require('nvim-tree.api')
        local function opts(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer, opts('Open: In Place'))
        vim.keymap.del('n', '<C-e>', { buffer = bufnr })
    end

    require("nvim-tree").setup {
        on_attach = on_attach,
        reload_on_bufenter = true,
        update_focused_file = { enable = true },
        view = {
            width = 30,
        },
        renderer = {
            group_empty = true,
        },
        filters = {
            dotfiles = true,
        },
    }
end

return M
