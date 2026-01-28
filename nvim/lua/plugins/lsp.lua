-- LSP plugins and configuration

return {
    -- Mason for LSP/DAP/linter installation
    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup {}
        end,
    },

    -- Mason LSP configuration
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        config = function()
            require('mason-lspconfig').setup {
                ensure_installed = {},
            }
        end,
    },

    -- LSP configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "mason-org/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            -- List of all pre-configured LSP servers:
            -- github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
            local servers = { 'pylsp', 'clangd', 'vimls', 'lua_ls' }
            -- integrate lspconfig to autocomplete
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            for _, lsp in pairs(servers) do
                if vim.fn.executable(lsp) then
                    require('lspconfig')[lsp].setup {
                        capabilities = capabilities
                    }
                end
            end
        end,
    },

    -- NLSP settings for LSP configuration
    {
        "tamago324/nlsp-settings.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
        config = function()
            require("nlspsettings").setup({
                config_home = vim.fn.stdpath('config') .. '/nlsp-settings',
                local_settings_dir = ".nlsp-settings",
                local_settings_root_markers_fallback = { '.git' },
                append_default_schemas = true,
                loader = 'json'
            })
        end,
    },

    -- LSP saga (commented)
    -- {
    --     "glepnir/lspsaga.nvim",
    --     config = function()
    --         require("lspsaga").setup {
    --             lightbulb = {
    --                 enable = false,
    --             }
    --         }
    --     end,
    -- },

    -- Null-ls for formatters and linters (commented)
    -- {
    --     "jose-elias-alvarez/null-ls.nvim",
    --     dependencies = { "nvim-lua/plenary.nvim" },
    --     config = function()
    --         local null_ls = require("null-ls")
    --         local sources = {
    --             -- python
    --             null_ls.builtins.formatting.isort,
    --             null_ls.builtins.formatting.yapf,
    --             null_ls.builtins.formatting.autoflake,
    --             -- lua
    --             null_ls.builtins.formatting.lua_format,
    --             -- shell
    --             null_ls.builtins.formatting.shfmt,
    --             null_ls.builtins.diagnostics.shellcheck,
    --         }
    --         null_ls.setup({ sources = sources })
    --     end,
    -- },
}
