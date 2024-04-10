local M = {}

function M.config()
    -- Setup github copilot.
    vim.keymap.set('i', '<C-e>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false
    })
    vim.g.copilot_no_tab_map = true
    -- Setup nvim-cmp.
    local function replace_keys(str)
        return vim.api.nvim_replace_termcodes(str, true, true, true)
    end
    local cmp = require 'cmp'
    cmp.setup({
        snippet = {
            -- REQUIRED - you must specify a snippet engine
            expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping(function(fallback)
                fallback()
            end, { 'i' }),
            ['<C-k>'] = cmp.mapping.confirm({ select = true }),
            ['<C-j>'] = cmp.mapping(function(fallback)
                if vim.call('vsnip#jumpable', 1) ~= 0 then
                    vim.fn.feedkeys(replace_keys('<Plug>(vsnip-jump-next)'), '')
                    fallback()
                end
            end, { 'i', 's' }),
            ['<C-l>'] = cmp.mapping(function(fallback)
                if vim.call('vsnip#jumpable', -1) ~= 0 then
                    vim.fn.feedkeys(replace_keys('<Plug>(vsnip-jump-prev)'), '')
                    fallback()
                end
            end, { 'i', 's' }),
            ['<CR>'] = cmp.mapping(function(fallback)
                if vim.call('vsnip#expandable') ~= 0 then
                    vim.fn.feedkeys(replace_keys('<Plug>(vsnip-expand)'), '')
                else
                    fallback()
                end
            end, { 'i', 's' }),
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
            { name = 'vsnip' },
        }, {
            { name = 'buffer' },
        }, {
            { name = 'path' },
        })
    })

    -- Set configuration for specific filetype.
    cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
            { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
        }, {
            { name = 'buffer' },
        })
    })

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' }
        }
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })

    local glance = require('glance')
    local actions = glance.actions

    glance.setup({
        height = 18,         -- Height of the window
        zindex = 45,
        preview_win_opts = { -- Configure preview window options
            cursorline = true,
            number = true,
            wrap = true,
        },
        border = {
            enable = false, -- Show window borders. Only horizontal borders allowed
            top_char = '―',
            bottom_char = '―',
        },
        list = {
            position = 'right', -- Position of the list window 'left'|'right'
            width = 0.33,       -- 33% width relative to the active window, min 0.1, max 0.5
        },
        theme = {               -- This feature might not work properly in nvim-0.7.2
            enable = true,      -- Will generate colors for the plugin based on your current colorscheme
            mode = 'auto',      -- 'brighten'|'darken'|'auto', 'auto' will set mode based on the brightness of your colorscheme
        },
        mappings = {
            list = {
                ['j'] = actions.next,     -- Bring the cursor to the next item in the list
                ['k'] = actions.previous, -- Bring the cursor to the previous item in the list
                ['<Down>'] = actions.next,
                ['<Up>'] = actions.previous,
                ['<Tab>'] = actions.next_location,       -- Bring the cursor to the next location skipping groups in the list
                ['<S-Tab>'] = actions.previous_location, -- Bring the cursor to the previous location skipping groups in the list
                ['<C-u>'] = actions.preview_scroll_win(5),
                ['<C-d>'] = actions.preview_scroll_win(-5),
                ['v'] = actions.jump_vsplit,
                ['s'] = actions.jump_split,
                ['t'] = actions.jump_tab,
                ['<CR>'] = actions.jump,
                ['o'] = actions.jump,
                ['<leader>l'] = actions.enter_win('preview'), -- Focus preview window
                ['q'] = actions.close,
                ['Q'] = actions.close,
                ['<Esc>'] = actions.close,
                -- ['<Esc>'] = false -- disable a mapping
            },
            preview = {
                ['Q'] = actions.close,
                ['<Tab>'] = actions.next_location,
                ['<S-Tab>'] = actions.previous_location,
                ['<leader>l'] = actions.enter_win('list'), -- Focus list window
            },
        },
        hooks = {},
        folds = {
            fold_closed = '',
            fold_open = '',
            folded = true, -- Automatically fold list on startup
        },
        indent_lines = {
            enable = true,
            icon = '│',
        },
        winbar = {
            enable = true, -- Available strating from nvim-0.8+
        },
    })

    require("trouble").setup {
        position = "bottom", -- position of the list can be: bottom, top, left, right
        height = 10, -- height of the trouble list when position is top or bottom
        width = 50, -- width of the list when position is left or right
        icons = true, -- use devicons for filenames
        mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
        fold_open = "", -- icon used for open folds
        fold_closed = "", -- icon used for closed folds
        group = true, -- group results by file
        padding = true, -- add an extra new line on top of the list
        action_keys = { -- key mappings for actions in the trouble list
            -- map to {} to remove a mapping, for example:
            -- close = {},
            close = "q",                   -- close the list
            cancel = "<esc>",              -- cancel the preview and get back to your last window / buffer / cursor
            refresh = "r",                 -- manually refresh
            jump = { "<cr>", "<tab>" },    -- jump to the diagnostic or open / close folds
            open_split = { "<c-x>" },      -- open buffer in new split
            open_vsplit = { "<c-v>" },     -- open buffer in new vsplit
            open_tab = { "<c-t>" },        -- open buffer in new tab
            jump_close = { "o" },          -- jump to the diagnostic and close the list
            toggle_mode = "m",             -- toggle between "workspace" and "document" diagnostics mode
            toggle_preview = "P",          -- toggle auto_preview
            hover = "K",                   -- opens a small popup with the full multiline message
            preview = "p",                 -- preview the diagnostic location
            close_folds = { "zM", "zm" },  -- close all folds
            open_folds = { "zR", "zr" },   -- open all folds
            toggle_fold = { "zA", "za" },  -- toggle fold of current file
            previous = "k",                -- previous item
            next = "j"                     -- next item
        },
        indent_lines = true,               -- add an indent guide below the fold icons
        auto_open = false,                 -- automatically open the list when you have diagnostics
        auto_close = false,                -- automatically close the list when you have no diagnostics
        auto_preview = true,               -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
        auto_fold = false,                 -- automatically fold a file trouble list at creation
        auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
        signs = {
            -- icons / text used for a diagnostic
            error = "",
            warning = "",
            hint = "",
            information = "",
            other = "﫠"
        },
        use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
    }
    -- Function to check if a floating dialog exists and if not
    -- then check for diagnostics under the cursor
    function OpenDiagnosticIfNoFloat()
        for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_config(winid).zindex then
                return
            end
        end
        -- THIS IS FOR BUILTIN LSP
        vim.diagnostic.open_float(0, {
            scope = "cursor",
            focusable = false,
            close_events = {
                "CursorMoved",
                "CursorMovedI",
                "BufHidden",
                "InsertCharPre",
                "WinLeave",
            },
        })
    end

    -- Show diagnostics under the cursor when holding position
    vim.api.nvim_create_augroup("lsp_diagnostics_hold", { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold" }, {
        pattern = "*",
        command = "lua OpenDiagnosticIfNoFloat()",
        group = "lsp_diagnostics_hold",
    })
end

return M
