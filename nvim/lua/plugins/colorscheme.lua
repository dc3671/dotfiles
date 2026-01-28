-- Colorscheme plugins

return {
    -- OneDark theme (active)
    {
        "navarasu/onedark.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("set background=dark")
            require('onedark').setup {
                style = 'warmer',
                code_style = {
                    comments = 'none',
                }
            }
            require('onedark').load()
        end,
    },

    -- Edge theme (alternative)
    {
        "sainnhe/edge",
        lazy = false,
        config = function()
            -- Uncomment to use edge theme:
            -- vim.g.edge_style = 'aura' -- neon, aura
            -- vim.g.edge_better_performance = 1
            -- vim.g.edge_disable_italic_comment = 1
            -- vim.cmd("colorscheme edge")
        end,
    },

    -- Other themes (commented, kept for reference)
    -- "sainnhe/sonokai",
    -- "tiagovla/tokyodark.nvim",
    -- "projekt0n/github-nvim-theme",
    -- { "catppuccin/nvim", name = "catppuccin" },
    -- { "sonph/onehalf", dir = "vim/" },
    -- "liuchengxu/space-vim-dark",
    -- "ahmedabdulrahman/aylin.vim",
    -- "rebelot/kanagawa.nvim",
    -- "NLKNguyen/papercolor-theme",
    -- "B4mbus/oxocarbon-lua.nvim",
    -- "Th3Whit3Wolf/one-nvim",
}
