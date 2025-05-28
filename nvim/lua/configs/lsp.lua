local M = {}

function M.config()
    local nlspsettings = require("nlspsettings")

    nlspsettings.setup({
        config_home = vim.fn.stdpath('config') .. '/nlsp-settings',
        local_settings_dir = ".nlsp-settings",
        local_settings_root_markers_fallback = { '.git' },
        append_default_schemas = true,
        loader = 'json'
    })

    -- nvim-lspconfig config
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
    local mason_ok, mason = pcall(require, "mason")
    if mason_ok then
        mason.setup {}
        require('mason-lspconfig').setup {
            ensure_installed = {},
        }
        -- require('mason-lspconfig').setup_handlers {
        --     function(server_name)
        --         require("lspconfig")[server_name].setup {}
        --     end
        -- }
    end
    local null_ls_ok, null_ls = pcall(require, "null-ls")
    if null_ls_ok then
        local sources = {
            -- python
            null_ls.builtins.formatting.isort,
            -- null_ls.builtins.formatting.black,
            null_ls.builtins.formatting.yapf,
            null_ls.builtins.formatting.autoflake,
            -- lua
            null_ls.builtins.formatting.lua_format,
            -- shell
            null_ls.builtins.formatting.shfmt,
            null_ls.builtins.diagnostics.shellcheck,
        }
        null_ls.setup({ sources = sources })
    end

    -- require("lspsaga").setup {
    --     lightbulb = {
    --         enable = false,
    --     }
    -- }
end

return M
