-- Completion plugins and configuration

return {
    -- nvim-cmp - completion engine
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local cmp = require 'cmp'
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping(function(fallback)
                        fallback()
                    end, { 'i' }),
                    ['<C-k>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                }, {
                    { name = 'buffer' },
                }, {
                    { name = 'path' },
                })
            })

            -- Set configuration for specific filetype.
            cmp.setup.filetype('gitcommit', {
                sources = cmp.config.sources({
                    { name = 'git' },
                }, {
                    { name = 'buffer' },
                })
            })

            -- Use buffer source for `/` and `?`
            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            -- Use cmdline & path source for ':'
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end,
    },

    -- Completion sources
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "rafamadriz/friendly-snippets",

    -- Copilot integration
    {
        "github/copilot.vim",
        config = function()
            -- Setup github copilot
            vim.keymap.set('i', '<C-e>', 'copilot#Accept("\\<End>")', {
                expr = true,
                replace_keycodes = false
            })
            vim.g.copilot_no_tab_map = true
        end,
    },

    -- Glance for LSP references/definitions
    {
        "dnlhc/glance.nvim",
        config = function()
            local glance = require('glance')
            local actions = glance.actions

            glance.setup({
                height = 18,
                zindex = 45,
                preview_win_opts = {
                    cursorline = true,
                    number = true,
                    wrap = true,
                },
                border = {
                    enable = false,
                    top_char = '―',
                    bottom_char = '―',
                },
                list = {
                    position = 'right',
                    width = 0.33,
                },
                theme = {
                    enable = true,
                    mode = 'auto',
                },
                mappings = {
                    list = {
                        ['j'] = actions.next,
                        ['k'] = actions.previous,
                        ['<Down>'] = actions.next,
                        ['<Up>'] = actions.previous,
                        ['<Tab>'] = actions.next_location,
                        ['<S-Tab>'] = actions.previous_location,
                        ['<C-u>'] = actions.preview_scroll_win(5),
                        ['<C-d>'] = actions.preview_scroll_win(-5),
                        ['v'] = actions.jump_vsplit,
                        ['s'] = actions.jump_split,
                        ['t'] = actions.jump_tab,
                        ['<CR>'] = actions.jump,
                        ['o'] = actions.jump,
                        ['<leader>l'] = actions.enter_win('preview'),
                        ['q'] = actions.close,
                        ['Q'] = actions.close,
                        ['<Esc>'] = actions.close,
                    },
                    preview = {
                        ['Q'] = actions.close,
                        ['<Tab>'] = actions.next_location,
                        ['<S-Tab>'] = actions.previous_location,
                        ['<leader>l'] = actions.enter_win('list'),
                    },
                },
                hooks = {},
                folds = {
                    fold_closed = '',
                    fold_open = '',
                    folded = true,
                },
                indent_lines = {
                    enable = true,
                    icon = '│',
                },
                winbar = {
                    enable = true,
                },
            })
        end,
    },

    -- Trouble for diagnostics
    {
        "folke/trouble.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("trouble").setup {
                position = "bottom",
                height = 10,
                width = 50,
                icons = true,
                mode = "workspace_diagnostics",
                fold_open = "",
                fold_closed = "",
                group = true,
                padding = true,
                action_keys = {
                    close = "q",
                    cancel = "<esc>",
                    refresh = "r",
                    jump = { "<cr>", "<tab>" },
                    open_split = { "<c-x>" },
                    open_vsplit = { "<c-v>" },
                    open_tab = { "<c-t>" },
                    jump_close = { "o" },
                    toggle_mode = "m",
                    toggle_preview = "P",
                    hover = "K",
                    preview = "p",
                    close_folds = { "zM", "zm" },
                    open_folds = { "zR", "zr" },
                    toggle_fold = { "zA", "za" },
                    previous = "k",
                    next = "j"
                },
                indent_lines = true,
                auto_open = false,
                auto_close = false,
                auto_preview = true,
                auto_fold = false,
                auto_jump = { "lsp_definitions" },
                signs = {
                    error = "",
                    warning = "",
                    hint = "",
                    information = "",
                    other = "﫠"
                },
                use_diagnostic_signs = false
            }
        end,
    },

    -- Snippets (commented)
    -- "hrsh7th/cmp-vsnip",
    -- "hrsh7th/vim-vsnip",
}
