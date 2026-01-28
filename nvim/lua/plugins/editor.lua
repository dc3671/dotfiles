-- Editor enhancement plugins

return {
    -- Surround text objects
    {
        "kylechui/nvim-surround",
        config = function()
            require("nvim-surround").setup {}
        end,
    },

    -- Auto pairs
    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup {}
        end,
    },

    -- Comment toggle
    {
        "numToStr/Comment.nvim",
        config = function()
            require('Comment').setup {
                ignore = '^$',
                padding = true,
                toggler = {
                    line = '<leader>cc',
                    block = '<leader>bc',
                },
                opleader = {
                    line = '<leader>c',
                    block = '<leader>b',
                },
            }
        end,
    },

    -- Unimpaired - quick navigation with [ and ]
    {
        "tummetott/unimpaired.nvim",
        config = function()
            require('unimpaired').setup {}
        end,
    },

    -- Multi cursors
    "mg979/vim-visual-multi",

    -- Better buffer delete
    "moll/vim-bbye",
}
