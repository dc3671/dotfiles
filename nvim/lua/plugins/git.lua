-- Git plugins and configuration

return {
    -- Gitsigns
    {
        "lewis6991/gitsigns.nvim",
        config = function()
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
        end,
    },

    -- Git conflict
    {
        "akinsho/git-conflict.nvim",
        config = function()
            require('git-conflict').setup {}
        end,
    },
}
