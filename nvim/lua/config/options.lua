-- Basic Neovim options and settings

-- Disable deprecation warnings
vim.deprecate = function() end

-- Command aliases for common typos
vim.cmd([[
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

-- Leader key
vim.g.mapleader = ','

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

-- Terminal GUI colors
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

-- Diagnostic configuration
vim.diagnostic.config { virtual_text = false }
