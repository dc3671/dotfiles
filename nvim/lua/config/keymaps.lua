-- Background toggle functions
local function set_bg_light()
    local colors_name = vim.g.colors_name
    vim.cmd('set background=light')
    vim.cmd('colorscheme shine')
    vim.cmd('colorscheme ' .. colors_name)
end

local function set_bg_dark()
    local colors_name = vim.g.colors_name
    vim.cmd('set background=dark')
    vim.cmd('colorscheme ron')
    vim.cmd('colorscheme ' .. colors_name)
end

-- Keymap helper
local keymap = vim.keymap.set

-- Background toggles
keymap('n', '<leader>vl', set_bg_light)
keymap('n', '<leader>vd', set_bg_dark)

-- Scrolling
keymap('n', 'zl', 'zL')
keymap('n', 'zh', 'zH')

-- Quick move in normal/visual mode
keymap({ 'n', 'v' }, 'H', '0')
keymap({ 'n', 'v' }, 'L', '$')

-- Quick move in insert mode
local insert_moves = {
    ['<C-o>'] = '<Esc>o',
    ['<C-a>'] = '<Home>',
    ['<C-e>'] = '<End>',
    ['<C-b>'] = '<Left>',
    ['<C-f>'] = '<Right>',
    ['<C-d>'] = '<Delete>',
    ['<A-h>'] = '<Left>',
    ['<A-j>'] = '<Down>',
    ['<A-k>'] = '<Up>',
    ['<A-l>'] = '<Right>',
}
for lhs, rhs in pairs(insert_moves) do
    keymap('i', lhs, rhs)
end

-- Select all
keymap('n', '<C-a>', 'ggVG')
keymap('n', '<leader>sa', 'ggVG')
keymap('n', '<C-x>', '<Nop>')

-- Replace paste yanked text without yanking the deleted text
keymap('v', 'p', '"_dP')

-- Visual shifting (does not exit Visual mode)
keymap('v', '<', '<gv')
keymap('v', '>', '>gv')

-- Workspace/Panel toggles
keymap('n', '<C-e>', ':NvimTreeToggle<cr>')
keymap('n', '<C-t>', ':AerialToggle!<cr>')

-- FZF
keymap("n", "<C-f>", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
keymap("n", "<C-p>", "<cmd>lua require('fzf-lua').git_files()<CR>", { silent = true })
keymap("n", "<C-b>", "<cmd>lua require('fzf-lua').buffers()<CR>", { silent = true })
keymap("n", "<C-g>", "<cmd>lua require('fzf-lua').grep()<CR>", { silent = true })

-- Copilot
keymap({'n', 'v'}, '<leader>pp', ':CopilotChat')
keymap({ 'n', 'v' }, '<leader>pe', ':CopilotChatExplain<CR>')
keymap({ 'n', 'v' }, '<leader>pr', ':CopilotChatReview<CR>')
keymap({ 'n', 'v' }, '<leader>pf', ':CopilotChatFix<CR>')
keymap({ 'n', 'v' }, '<leader>po', ':CopilotChatOptimize<CR>')

-- Window management
keymap('n', '<leader>w1', '<c-w>o')
keymap('n', '<leader>wx', ':x<cr>')
keymap('n', '<leader>w2', ':sp<cr>')
keymap('n', '<leader>w3', ':vs<cr>')
keymap('n', '<c-j>', '<c-w>j')
keymap('n', '<c-k>', '<c-w>k')
keymap('n', '<c-l>', '<c-w>l')
keymap('n', '<c-h>', '<c-w>h')

-- Wrapped lines navigation
keymap('n', 'j', 'gj')
keymap('n', 'k', 'gk')
keymap('v', 'j', 'gj')
keymap('v', 'k', 'gk')

-- Window resize
keymap('n', '<m-9>', '<c-w><')
keymap('n', '<m-0>', '<c-w>>')
keymap('n', '<m-->', '<c-w>-')
keymap('n', '<m-=>', '<c-w>+')

-- Buffer navigation
keymap('n', 'm', ':bn<cr>')
keymap('n', 'M', ':bp<cr>')
keymap('n', 't', '<C-^>')
keymap('n', 'qq', ':Bwipeout<cr>')

-- Plugins
keymap('n', '<leader>pi', ':PackerInstall<cr>')
keymap('n', '<leader>pc', ':PackerClean<cr>')

-- Find
keymap('n', '<leader>fw', '/\\<lt>\\><left><left>')
keymap('n', '<leader>fc', '/\\v^[<\\|=>]{7}( .*\\|$)<CR>')
keymap('n', '<leader>/', ':set invhlsearch<cr>')

-- Diagnostics
keymap('n', '<leader>ef', vim.diagnostic.open_float)
keymap('n', '<leader>ee', ':TroubleToggle workspace_diagnostics<cr>')
keymap('n', '<leader>el', ':TroubleToggle document_diagnostics<cr>')

-- LSP
keymap('n', '<leader>lk', function() vim.lsp.buf.hover {} end)
keymap('n', '<leader>ld', function() vim.lsp.buf.definition {} end)
keymap('n', '<leader>lt', function() vim.lsp.buf.type_definition {} end)
keymap('n', '<leader>li', function() vim.lsp.buf.implementation {} end)
keymap('n', '<leader>lr', function() vim.lsp.buf.rename {} end)
keymap('n', '<leader>lh', function() vim.lsp.buf.signature_help {} end)
keymap('n', '<leader>la', function() vim.lsp.buf.code_action {} end)
keymap({ 'n', 'v' }, '<leader>lf', function() vim.lsp.buf.format { async = true } end)

-- Glance
keymap('n', '<leader>gd', ':Glance definitions<CR>')
keymap('n', '<F4>', ':Glance references<CR>')
keymap('n', '<leader>gt', ':Glance type_definitions<CR>')
keymap('n', '<leader>gi', ':Glance implementations<CR>')

-- Diagnostics navigation
keymap('n', '[e', vim.diagnostic.goto_prev)
keymap('n', ']e', vim.diagnostic.goto_next)

-- Workspace folders
keymap('n', '<leader>wa', vim.lsp.buf.add_workspace_folder)
keymap('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder)
keymap('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)

-- Terminal
local terminal = require('toggleterm.terminal')
keymap('n', '<leader>tt', ':ToggleTerm direction=tab<cr>')
keymap('n', '<leader>tn', function() terminal.Terminal:new():toggle() end)
keymap('n', '<leader>tf', ':ToggleTerm direction=float<cr>')
keymap('n', '<leader>th', ':ToggleTerm direction=horizontal<cr>')
keymap('n', '<leader>tv', ':ToggleTerm direction=vertical<cr>')

-- Git
keymap('n', '<leader>hu', ':Gitsigns undo_stage_hunk<cr>')
keymap('n', ']h', ':Gitsigns next_hunk<cr>')
keymap('n', '[h', ':Gitsigns prev_hunk<cr>')
keymap('n', '<leader>hc', ':Gitsigns preview_hunk<cr>')
keymap('n', '<leader>hr', ':Gitsigns reset_hunk<cr>')
keymap('n', '<leader>hR', ':Gitsigns reset_buffer')
keymap('n', '<leader>hb', ':Gitsigns blame_line<cr>')
keymap('n', '<leader>hd', ':Gitsigns diffthis<cr>')
keymap('n', '<leader>hs', ':<C-U>Gitsigns select_hunk<CR>')

-- Git conflict
keymap('n', '<leader>co', '<Plug>(git-conflict-ours)')
keymap('n', '<leader>ct', '<Plug>(git-conflict-theirs)')
keymap('n', '<leader>cb', '<Plug>(git-conflict-both)')
keymap('n', '<leader>c0', '<Plug>(git-conflict-none)')
keymap('n', ']x', '<Plug>(git-conflict-prev-conflict)')
keymap('n', '[x', '<Plug>(git-conflict-next-conflict)')

-- Spectre (replace across multi files)
keymap('n', '<leader>ss', '<cmd>lua require("spectre").open()<CR>', { desc = "Open Spectre" })
keymap('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', { desc = "Search current word" })
keymap('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = "Search current word" })
keymap('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', { desc = "Search on current file" })
