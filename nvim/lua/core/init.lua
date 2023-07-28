-- basicsinit
vim.cmd('syntax on')
vim.cmd('filetype plugin indent on')
-- avoid annoying shift key
vim.cmd([[ command! -bang -nargs=* -complete=file E e<bang> <args> ]])
vim.cmd([[ command! -bang -nargs=* -complete=file W w<bang> <args> ]])
vim.cmd([[ command! -bang -nargs=* -complete=file Wq wq<bang> <args> ]])
vim.cmd([[ command! -bang -nargs=* -complete=file WQ wq<bang> <args> ]])
vim.cmd([[ command! -bang Wa wa<bang> ]])
vim.cmd([[ command! -bang WA wa<bang> ]])
vim.cmd([[ command! -bang Q q<bang> ]])
vim.cmd([[ command! -bang QA qa<bang> ]])
vim.cmd([[ command! -bang Qa qa<bang> ]])

vim.opt.number         = true
vim.opt.relativenumber = false
vim.opt.shiftround     = true
vim.opt.updatetime     = 100
vim.opt.cursorline     = true
vim.opt.autowrite      = true
vim.opt.ignorecase     = true
vim.opt.virtualedit    = 'onemore' -- Allow for cursor beyond last character
vim.opt.foldmethod     = 'indent'
vim.opt.foldlevelstart = 99
-- Puts new split windows to the right and bottom of the current
vim.opt.splitright     = true
vim.opt.splitbelow     = true

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
vim.opt.wrap          = true
vim.opt.formatoptions = ''
-- undo
vim.opt.undofile      = true
vim.opt.undolevels    = 1000  -- Maximum number of changes that can be undone
vim.opt.undoreload    = 10000 -- Maximum number lines to save for undo on a buffer reload
vim.opt.list          = true
vim.opt.listchars     = { tab = ' ›', trail = '•', extends = '#', nbsp = '.' }

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

vim.diagnostic.config { virtual_text = false }

require("core.keymaps")

require("core.theme")

require('image').setup {
    min_padding = 5,
    show_label = true,
    render_using_dither = true,
}

-- Load plugin configs
-- plugins without extra configs are configured directly here
require("impatient")
require('Comment').setup {
    ignore = '^$',
    padding = false,
    toggler = {
        line = '<leader>cc',
        block = '<leader>bc',
    },
    opleader = {
        line = '<leader>c',
        block = '<leader>b',
    },
}
require("nvim-surround").setup {}
require('unimpaired').setup {}
require("nvim-autopairs").setup {}
require("aerial").setup {}
require("fzf-lua").setup {
    winopts = { preview = { flip_columns = 180 } },
    fzf_opts = { ['--layout'] = 'default' }
}
require('spectre').setup { default = { find = { cmd = "ag" } } }
require("auto-session").setup {
    log_level = "error",
    auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
}

require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}

require("configs.lsp").config()
require("configs.autocomplete").config()
require("configs.statusline").config()
require("configs.treesitter").config()
require("configs.git").config()
require("configs.bufferline").config()
require("configs.grammar").config()
require("configs.terminal").config()
require("configs.nvimtree").config()
--require("configs.ide").config()
require("configs.scrollbar").config()
