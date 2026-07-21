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
                ensure_installed = { 'pylsp', 'vimls', 'lua_ls' },
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
            -- clangd: memory-conscious launch flags (nvim 0.11 native config API).
            -- Biggest wins: PCH on disk (not RAM), malloc-trim returns freed pages
            -- to OS, fewer indexer threads = lower peak RSS.
            vim.lsp.config('clangd', {
                cmd = {
                    'clangd',
                    '--background-index',                -- persist index to .cache/clangd (disk), not RAM
                    '--background-index-priority=background',
                    '--pch-storage=disk',                -- preamble/PCH on disk; biggest anon-RSS save
                    '--malloc-trim',                     -- hand freed memory back to the OS
                    '-j=2',                              -- cap indexer threads; fewer = lower peak mem
                    '--limit-references=1000',
                    '--limit-results=200',
                    '--clang-tidy=false',                -- clang-tidy doubles parse cost + memory
                    '--header-insertion=never',
                },
            })
        end,
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
