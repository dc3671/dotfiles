-- UI plugins and configuration

return {
    -- Bufferline
    {
        "akinsho/bufferline.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            local bufferline = require('bufferline')
            bufferline.setup {
                options = {
                    style_preset = 4,
                    mode = "buffers",
                    numbers = "none",
                    close_command = "bdelete! %d",
                    right_mouse_command = "bdelete! %d",
                    left_mouse_command = "buffer %d",
                    middle_mouse_command = nil,
                    indicator = {
                        icon = '▎',
                        style = 'icon'
                    },
                    buffer_close_icon = '',
                    modified_icon = '●',
                    close_icon = '',
                    left_trunc_marker = '|',
                    right_trunc_marker = '|',
                    name_formatter = function(buf)
                        if buf.name:match('%.md') then
                            return vim.fn.fnamemodify(buf.name, ':t:r')
                        end
                    end,
                    max_name_length = 18,
                    max_prefix_length = 15,
                    tab_size = 18,
                    diagnostics = "nvim_lsp",
                    diagnostics_update_in_insert = false,
                    diagnostics_indicator = function(count, level, diagnostics_dict, context)
                        local s = " "
                        for e, n in pairs(diagnostics_dict) do
                            local sym = e == "error" and " "
                                or (e == "warning" and " " or "")
                            s = s .. sym
                        end
                        return s
                    end,
                    custom_filter = function(buf_number, buf_numbers)
                        if vim.bo[buf_number].filetype ~= "<i-dont-want-to-see-this>" then
                            return true
                        end
                        if vim.fn.bufname(buf_number) ~= "<buffer-name-I-dont-want>" then
                            return true
                        end
                        if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
                            return true
                        end
                        if buf_numbers[1] ~= buf_number then
                            return true
                        end
                    end,
                    offsets = {
                        { filetype = "bufferlist", text = "Explorer", text_align = "center" },
                        { filetype = "filetree", text = "Explorer", text_align = "center" },
                    },
                    color_icons = true,
                    show_buffer_icons = true,
                    show_buffer_close_icons = true,
                    show_close_icon = true,
                    show_tab_indicators = true,
                    persist_buffer_sort = true,
                    separator_style = "thin",
                    enforce_regular_tabs = false,
                    always_show_bufferline = true,
                    sort_by = 'id'
                }
            }
        end,
    },

    -- Lualine status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require('lualine').setup {
                options = {
                    icons_enabled = true,
                    component_separators = { left = '', right = '' },
                    section_separators = { left = '', right = '' },
                    disabled_filetypes = {},
                    always_divide_middle = true,
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff' },
                    lualine_c = { { 'filename', path = 1 } },
                    lualine_x = { 'aerial' },
                    lualine_y = { 'filetype' },
                    lualine_z = {
                        {
                            function()
                                local line = vim.fn.line('.')
                                local total = vim.api.nvim_buf_line_count(0)
                                local col = vim.fn.virtcol('.')
                                local percent = line / total * 100
                                return string.format('%.f%%%% L:%d/%d C:%-2d', percent, line, total, col)
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
        end,
    },

    -- Scrollbar
    {
        "petertriho/nvim-scrollbar",
        config = function()
            require("scrollbar").setup {
                show = true,
                show_in_active_only = false,
                set_highlights = true,
                folds = 1000,
                max_lines = false,
                hide_if_all_visible = false,
                throttle_ms = 100,
                handle = {
                    text = " ",
                    color = nil,
                    cterm = nil,
                    highlight = "CursorColumn",
                    hide_if_all_visible = true,
                },
                marks = {
                    Cursor = {
                        text = "•",
                        priority = 0,
                        color = nil,
                        cterm = nil,
                        highlight = "Normal",
                    },
                    Search = {
                        text = { "-", "=" },
                        priority = 1,
                        color = nil,
                        cterm = nil,
                        highlight = "Search",
                    },
                    Error = {
                        text = { "-", "=" },
                        priority = 2,
                        color = nil,
                        cterm = nil,
                        highlight = "DiagnosticVirtualTextError",
                    },
                    Warn = {
                        text = { "-", "=" },
                        priority = 3,
                        color = nil,
                        cterm = nil,
                        highlight = "DiagnosticVirtualTextWarn",
                    },
                    Info = {
                        text = { "-", "=" },
                        priority = 4,
                        color = nil,
                        cterm = nil,
                        highlight = "DiagnosticVirtualTextInfo",
                    },
                    Hint = {
                        text = { "-", "=" },
                        priority = 5,
                        color = nil,
                        cterm = nil,
                        highlight = "DiagnosticVirtualTextHint",
                    },
                    Misc = {
                        text = { "-", "=" },
                        priority = 6,
                        color = nil,
                        cterm = nil,
                        highlight = "Normal",
                    },
                    GitAdd = {
                        text = "┆",
                        priority = 7,
                        color = nil,
                        cterm = nil,
                        highlight = "GitSignsAdd",
                    },
                    GitChange = {
                        text = "┆",
                        priority = 7,
                        color = nil,
                        cterm = nil,
                        highlight = "GitSignsChange",
                    },
                    GitDelete = {
                        text = "▁",
                        priority = 7,
                        color = nil,
                        cterm = nil,
                        highlight = "GitSignsDelete",
                    },
                },
                excluded_buftypes = {
                    "terminal",
                },
                excluded_filetypes = {
                    "prompt",
                    "TelescopePrompt",
                    "noice",
                },
                autocmd = {
                    render = {
                        "BufWinEnter",
                        "TabEnter",
                        "TermEnter",
                        "WinEnter",
                        "CmdwinLeave",
                        "TextChanged",
                        "VimResized",
                        "WinScrolled",
                    },
                    clear = {
                        "BufWinLeave",
                        "TabLeave",
                        "TermLeave",
                        "WinLeave",
                    },
                },
                handlers = {
                    cursor = true,
                    diagnostic = true,
                    gitsigns = false,
                    handle = true,
                    search = false,
                },
            }
        end,
    },

    -- Indent blankline
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("ibl").setup {}
        end,
    },

    -- Image display
    {
        "samodostal/image.nvim",
        config = function()
            require('image').setup {
                min_padding = 5,
                show_label = true,
                render_using_dither = true,
            }
        end,
    },
}
