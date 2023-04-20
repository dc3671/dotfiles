-- basicsinit
vim.cmd('syntax on')
vim.cmd('filetype plugin indent on')
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.number         = true
vim.opt.relativenumber = false 
vim.opt.termguicolors  = true
vim.opt.shiftround     = true
vim.opt.updatetime     = 100
vim.opt.cursorline     = true
vim.opt.autowrite      = true
if (vim.fn.has('termguicolors') == 1) then
    vim.opt.termguicolors = true
end
-- tabs
vim.opt.autoindent    = true
vim.opt.tabstop       = 4
vim.opt.shiftwidth    = 4
vim.opt.softtabstop   = 4
vim.opt.mouse         = 'a'
vim.opt.expandtab     = true
vim.opt.autowrite     = false
vim.opt.wrap          = false
vim.opt.formatoptions = ''
--vim.opt.listchars     = { tab = '›', trail = '•', extends = '#' }

require("core.plugins")
--require("core.gui")
-- disable some useless standard plugins to save startup time
-- these features have been better covered by plugins
vim.g.loaded_matchparen        = 1
vim.g.loaded_matchit           = 1
vim.g.loaded_logiPat           = 1
vim.g.loaded_rrhelper          = 1
vim.g.loaded_tarPlugin         = 1
vim.g.loaded_gzip              = 1
vim.g.loaded_zipPlugin         = 1
vim.g.loaded_2html_plugin      = 1
vim.g.loaded_shada_plugin      = 1
vim.g.loaded_spellfile_plugin  = 1
vim.g.loaded_netrw             = 1
vim.g.loaded_netrwPlugin       = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_remote_plugins    = 1
require("core.theme")

require('image').setup {
    min_padding = 5,
    show_label = true,
    render_using_dither = true,
}

-- Load plugin configs
-- plugins without extra configs are configured directly here
require("impatient")
-- require("nvim-tree").setup {}
-- require("nvim_comment").setup {}

require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}

require("configs.autocomplete").config()
require("configs.statusline").config()
require("configs.treesitter").config()
require("configs.startscreen").config()
require("configs.git").config()
require("configs.bufferline").config()
require("configs.grammar").config()
require("configs.terminal").config()
require("configs.ide").config()
require("configs.scrollbar").config()
--require("configs.telescope").config()

require("core.keymaps")
