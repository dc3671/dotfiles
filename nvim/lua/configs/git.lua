local M = {}
function M.config()
    require('gitsigns').setup {
        signs = {
            add          = { text = '│' },
            change       = { text = '│' },
            delete       = { text = '_' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
        },
        current_line_blame = true,
    }
    require('git-conflict').setup {}
end

return M
