local M = {}
function M.config()
    -- lualine config
    require('lualine').setup {
        options = {
            icons_enabled = true,
            theme = 'edge', -- based on current vim colorscheme
            -- not a big fan of fancy triangle separators
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            disabled_filetypes = {},
            always_divide_middle = true,
        },
        sections = {
            -- left
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff' },
            lualine_c = { { 'filename', path = 1 } },
            -- right
            lualine_x = { 'aerial' },
            lualine_y = { 'filetype' },
            lualine_z = {
                {
                    -- custom location
                    function()
                        local line = vim.fn.line('.')
                        local total = vim.api.nvim_buf_line_count(0)
                        local col = vim.fn.virtcol('.')
                        local percent = line / total * 100
                        return string.format('%.f%%%% :%d/%d☰ ℅:%-2d', percent, line, total, col)
                    end
                },
                {
                    function()
                        local starts = vim.fn.line("v")
                        local ends = vim.fn.line(".")
                        local count = starts <= ends and ends - starts + 1 or starts - ends + 1
                        return count .. "V"
                    end,
                    cond = function()
                        return vim.fn.mode():find("[Vv]") ~= nil
                    end,
                },
            },
        },
        inactive_sections = {
            lualine_a = { 'filename' },
            lualine_b = {},
            lualine_c = {},
            lualine_x = { 'location' },
            lualine_y = {},
            lualine_z = {}
        },
        tabline = {},
        extensions = { 'fzf', 'symbols-outline', 'nvim-tree' }
    }
end

return M
