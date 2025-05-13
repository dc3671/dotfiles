-- Basic Neovim initialization

vim.deprecate = function() end

-- Syntax and filetype
vim.cmd([[
  syntax on
  filetype plugin indent on
  command! -bang -nargs=* -complete=file E e<bang> <args>
  command! -bang -nargs=* -complete=file W w<bang> <args>
  command! -bang -nargs=* -complete=file Wq wq<bang> <args>
  command! -bang -nargs=* -complete=file WQ wq<bang> <args>
  command! -bang Wa wa<bang>
  command! -bang WA wa<bang>
  command! -bang Q q<bang>
  command! -bang QA qa<bang>
  command! -bang Qa qa<bang>
]])

-- General options
vim.opt.number         = true
vim.opt.relativenumber = false
vim.opt.shiftround     = true
vim.opt.updatetime     = 100
vim.opt.cursorline     = true
vim.opt.autowrite      = false
vim.opt.ignorecase     = true
vim.opt.virtualedit    = 'onemore'
vim.opt.foldmethod     = 'indent'
vim.opt.foldlevelstart = 99
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.pumheight      = 30

if vim.fn.has('termguicolors') == 1 then
    vim.opt.termguicolors = true
end

-- Tabs and indentation
vim.opt.autoindent    = true
vim.opt.tabstop       = 4
vim.opt.shiftwidth    = 4
vim.opt.softtabstop   = 4
vim.opt.expandtab     = true

vim.opt.mouse         = 'a'
vim.opt.wrap          = true
vim.opt.formatoptions = ''

-- Undo
vim.opt.undofile      = true
vim.opt.undolevels    = 1000
vim.opt.undoreload    = 10000

-- Listchars
vim.opt.list          = true
vim.opt.listchars     = { tab = ' ›', trail = '•', extends = '#', nbsp = '.' }

-- Disable standard plugins (faster startup)
local disabled_built_ins = {
  "matchparen", "matchbracket", "matchit", "logiPat", "rrhelper",
  "tarPlugin", "gzip", "zipPlugin", "2html_plugin", "shada_plugin",
  "spellfile_plugin", "netrw", "netrwPlugin", "tutor_mode_plugin", "remote_plugins"
}
for _, plugin in ipairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

vim.diagnostic.config { virtual_text = false }

-- Plugin and config requires
require("core.plugins")
require("core.keymaps")
require("core.theme")

require('image').setup {
    min_padding = 5,
    show_label = true,
    render_using_dither = true,
}

require("impatient")
require('Comment').setup {
    ignore = '^$',
    padding = true,
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
require("CopilotChat").setup {
    selection = function(source)
        local select = require("CopilotChat.select")
        return select.visual(source) or select.buffer(source)
    end
}
require("fzf-lua").setup {
    winopts = { preview = { flip_columns = 150 } },
    fzf_opts = { ['--layout'] = 'default' },
    files = { rg_opts = [[--color=never --files --hidden --follow -g "!.git" -g "!*.cubin.cpp*"]], },
    git = { files = { cmd = 'git ls-files --exclude-standard -- ":!:*.cubin.cpp*"' } },
    grep = { rg_opts = '--column --line-number --no-heading --color=always -g "!*.cubin.cpp*" --smart-case --max-columns=4096 -e' }
}
require('spectre').setup { default = { find = { cmd = "rg" } } }
require("auto-session").setup {
    log_level = "error",
    auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
}
require("ibl").setup {}

-- Load plugin configs
require("configs.lsp").config()
require("configs.autocomplete").config()
require("configs.statusline").config()
require("configs.treesitter").config()
require("configs.git").config()
require("configs.bufferline").config()
require("configs.grammar").config()
require("configs.terminal").config()
require("configs.nvimtree").config()
require("configs.scrollbar").config()
