vim.g.mapleader = ','

local function set_bg_light()
    vim.cmd('set background=light')
    local colors_name = vim.g.colors_name
    vim.cmd('colorscheme shine')
    vim.cmd('colorscheme ' .. colors_name)
end

local function set_bg_dark()
    vim.cmd('set background=dark')
    local colors_name = vim.g.colors_name
    vim.cmd('colorscheme ron')
    vim.cmd('colorscheme ' .. colors_name)
end

-- keymaps
vim.keymap.set('n', '<leader>vl', set_bg_light)
vim.keymap.set('n', '<leader>vd', set_bg_dark)
-- scrolling
vim.keymap.set('n', 'zl', 'zL')
vim.keymap.set('n', 'zh', 'zH')
-- quick move in normal mode
vim.keymap.set({ 'n', 'v' }, 'H', '0')
vim.keymap.set({ 'n', 'v' }, 'L', '$')
-- quick move in insert mode
vim.keymap.set('i', '<C-o>', '<Esc>o')
vim.keymap.set('i', '<C-a>', '<Home>')
vim.keymap.set('i', '<C-e>', '<End>')
vim.keymap.set('i', '<C-d>', '<Backspace>')
vim.keymap.set('i', '<A-h>', '<Left>')
vim.keymap.set('i', '<A-j>', '<Down>')
vim.keymap.set('i', '<A-k>', '<Up>')
vim.keymap.set('i', '<A-l>', '<Right>')
-- select all
vim.keymap.set('n', '<leader>sa', 'ggVG')
-- replace paste yanked text without yanking the deleted text
vim.keymap.set('v', 'p', '"_dP')
-- Visual shifting (does not exit Visual mode)
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- w: workspace
vim.keymap.set('n', '<C-e>', ':Workspace LeftPanelToggle<cr>')
vim.keymap.set('n', '<C-t>', ':Workspace RightPanelToggle<cr>')
-- y: fzf
vim.keymap.set("n", "<C-f>", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
vim.keymap.set("n", "<C-p>", "<cmd>lua require('fzf-lua').git_files()<CR>", { silent = true })
vim.keymap.set("n", "<C-b>", "<cmd>lua require('fzf-lua').buffers()<CR>", { silent = true })
vim.keymap.set("n", "<C-g>", "<cmd>lua require('fzf-lua').grep()<CR>", { silent = true })
-- w: window
vim.keymap.set('n', '<leader>w1', '<c-w>o')
vim.keymap.set('n', '<leader>wx', ':x<cr>')
vim.keymap.set('n', '<leader>w2', ':sp<cr>')
vim.keymap.set('n', '<leader>w3', ':vs<cr>')
vim.keymap.set('n', '<c-j>', '<c-w>j')
vim.keymap.set('n', '<c-k>', '<c-w>k')
vim.keymap.set('n', '<c-l>', '<c-w>l')
vim.keymap.set('n', '<c-h>', '<c-w>h')
-- window resize
vim.keymap.set('n', '<m-9>', '<c-w><')
vim.keymap.set('n', '<m-0>', '<c-w>>')
vim.keymap.set('n', '<m-->', '<c-w>-')
vim.keymap.set('n', '<m-=>', '<c-w>+')
-- b: buffer
vim.keymap.set('n', 'm', ':bn<cr>')
vim.keymap.set('n', 'M', ':bp<cr>')
vim.keymap.set('n', 't', '<C-^>')
vim.keymap.set('n', 'qq', ':Bwipeout<cr>')
-- p: plugins
vim.keymap.set('n', '<leader>pi', ':PackerInstall<cr>')
vim.keymap.set('n', '<leader>pc', ':PackerClean<cr>')
-- s: search
vim.keymap.set('n', '<leader>fw', '/\\<lt>\\><left><left>')
vim.keymap.set('n', '<leader>fc', '/\\v^[<\\|=>]{7}( .*\\|$)<CR>')
vim.keymap.set('n', '<leader>/', ':set invhlsearch<cr>')
-- l/g/w: language
-- l: general
-- g: goto
-- w: workspace
-- e: diagnostics
-- vim.keymap.set('n', '<leader>ee', ':Lspsaga show_line_diagnostics<cr>')
-- vim.keymap.set('n', '<leader>ef', ':Lspsaga show_cursor_diagnostics<cr>')
vim.keymap.set('n', '<leader>ef', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>ee', ':TroubleToggle workspace_diagnostics<cr>') -- Show list of diagnostics across the workspace
vim.keymap.set('n', '<leader>el', ':TroubleToggle document_diagnostics<cr>')
vim.keymap.set('n', '<leader>lk', function() vim.lsp.buf.hover {} end)
vim.keymap.set('n', '<leader>ld', function() vim.lsp.buf.definition {} end)
vim.keymap.set('n', '<leader>lt', function() vim.lsp.buf.type_definition {} end)
vim.keymap.set('n', '<leader>li', function() vim.lsp.buf.implementation {} end)
vim.keymap.set('n', '<leader>lr', function() vim.lsp.buf.rename {} end)
vim.keymap.set('n', '<leader>lh', function() vim.lsp.buf.signature_help {} end)
vim.keymap.set('n', '<leader>la', function() vim.lsp.buf.code_action {} end)
vim.keymap.set({ 'n', 'v' }, '<leader>lf', function() vim.lsp.buf.format { async = true } end)

vim.keymap.set('n', '<leader>gd', ':Glance definitions<CR>')
vim.keymap.set('n', '<F4>', ':Glance references<CR>')
vim.keymap.set('n', '<leader>gt', ':Glance type_definitions<CR>')
vim.keymap.set('n', '<leader>gi', ':Glance implementations<CR>')
vim.keymap.set('n', '[e', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']e', vim.diagnostic.goto_next)

vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder)
vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder)
vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)

-- t: terminal
-- use <f5> to toggle terminal, this can be set in lua/configs/terminal.lua
-- the default position is also set in lua/configs/terminal.lua
local terminal = require('toggleterm.terminal')
--vim.keymap.set('t', '<C-g>', '<C-\\><C-n>')
vim.keymap.set('n', '<leader>tt', ':ToggleTerm direction=tab<cr>')
vim.keymap.set('n', '<leader>tn', function() terminal.Terminal:new():toggle() end)
vim.keymap.set('n', '<leader>tf', ':ToggleTerm direction=float<cr>')
vim.keymap.set('n', '<leader>th', ':ToggleTerm direction=horizontal<cr>')
vim.keymap.set('n', '<leader>tv', ':ToggleTerm direction=vertical<cr>')

-- h: git
vim.keymap.set('n', '<leader>hu', ':Gitsigns undo_stage_hunk<cr>')
vim.keymap.set('n', ']h', ':Gitsigns next_hunk<cr>')
vim.keymap.set('n', '[h', ':Gitsigns prev_hunk<cr>')
vim.keymap.set('n', '<leader>hc', ':Gitsigns preview_hunk<cr>')
vim.keymap.set('n', '<leader>hr', ':Gitsigns reset_hunk<cr>')
vim.keymap.set('n', '<leader>hR', ':Gitsigns reset_buffer')
vim.keymap.set('n', '<leader>hb', ':Gitsigns blame_line<cr>')
vim.keymap.set('n', '<leader>hd', ':Gitsigns diffthis<cr>')
vim.keymap.set('n', '<leader>hs', ':<C-U>Gitsigns select_hunk<CR>')
