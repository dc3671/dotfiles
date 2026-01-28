-- Navigation plugins

return {
    -- Nvim-tree file explorer
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
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
        end,
    },

    -- Aerial code outline
    {
        "stevearc/aerial.nvim",
        config = function()
            require("aerial").setup {}
        end,
    },

    -- FZF
    {
        "junegunn/fzf",
        build = "./install --all --no-update-rc",
    },

    -- FZF Lua wrapper
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("fzf-lua").setup {
                winopts = { preview = { flip_columns = 150 } },
                fzf_opts = { ['--layout'] = 'default' },
                files = { rg_opts = [[--color=never --files --hidden --follow -g "!.git" -g "!*.cubin.cpp*" -g "!*_cubin.cpp*"]], },
                git = { files = { cmd = 'git ls-files --exclude-standard -- ":!:*.cubin.cpp*" ":!:*_cubin.cpp"' } },
                grep = { rg_opts = '--column --line-number --no-heading --color=always -g "!*.cubin.cpp*" -g "!*_cubin.cpp*" --smart-case --max-columns=4096 -e' }
            }
        end,
    },

    -- Spectre for search and replace across files
    {
        "nvim-pack/nvim-spectre",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require('spectre').setup { default = { find = { cmd = "rg" } } }
        end,
    },

    -- Telescope (commented)
    -- "BurntSushi/ripgrep",
    -- {
    --     "nvim-telescope/telescope.nvim",
    --     dependencies = "nvim-lua/plenary.nvim"
    -- },

    -- Symbols outline (commented)
    -- "simrat39/symbols-outline.nvim",

    -- Nvim-IDE (commented)
    -- "ldelossa/nvim-ide",
}
