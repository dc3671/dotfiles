-- Terminal plugins and configuration

return {
    -- Toggleterm
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm").setup {
                size = 30,
                open_mapping = "<f5>",
                on_open = function() end,
                on_close = function() end,
                on_stdout = function() end,
                on_stderr = function() end,
                on_exit = function() end,
                hide_numbers = true,
                shade_filetypes = {},
                highlights = {},
                shade_terminals = true,
                shading_factor = '1',
                start_in_insert = true,
                insert_mappings = true,
                terminal_mappings = true,
                persist_size = true,
                persist_mode = true,
                direction = 'horizontal',
                close_on_exit = true,
                shell = vim.o.shell,
                auto_scroll = true,
                float_opts = {
                    border = 'single',
                    width = 140,
                    height = 50,
                    winblend = 1,
                },
                winbar = {
                    enabled = false,
                    name_formatter = function(term)
                        return term.name
                    end
                },
            }
        end,
    },
}
