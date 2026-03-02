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
                ensure_installed = { 'pylsp', 'vimls', 'lua_ls', 'clangd' },
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
    },

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
