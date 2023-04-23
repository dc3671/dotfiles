-- packer.nvim
vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function()
    use 'wbthomason/packer.nvim'

    use 'nvim-lua/plenary.nvim'
    use 'MunifTanjim/nui.nvim'

    -- IDE-like side panels
    use 'ldelossa/nvim-ide'
    -- use 'nvim-tree/nvim-tree.lua'
    -- use 'simrat39/symbols-outline.nvim'

    -- starup time optimise
    use 'dstein64/vim-startuptime'
    use 'lewis6991/impatient.nvim'

    -- buffer
    use {
        'akinsho/bufferline.nvim',
        requires = 'kyazdani42/nvim-web-devicons'
    }
    use 'moll/vim-bbye' -- for more sensible delete buffer cmd

    -- themes (disabled other themes to optimize startup time)
    -- use 'sainnhe/sonokai'
    -- use 'tiagovla/tokyodark.nvim'
    -- use 'projekt0n/github-nvim-theme'
    use 'navarasu/onedark.nvim'
    -- use { 'catppuccin/nvim', as='catppuccin' }
    -- use { 'sonph/onehalf', rtp='vim/' }
    -- use 'liuchengxu/space-vim-dark'
    -- use 'ahmedabdulrahman/aylin.vim'
    -- use 'rebelot/kanagawa.nvim'
    -- use 'NLKNguyen/papercolor-theme'
    -- use 'liuchengxu/space-vim-dark'
    use 'sainnhe/edge'
    -- use 'B4mbus/oxocarbon-lua.nvim'
    -- use 'Th3Whit3Wolf/one-nvim'

    -- package management
    use "williamboman/mason.nvim"
    -- lsp
    use "williamboman/mason-lspconfig.nvim"
    use 'neovim/nvim-lspconfig'
    --use 'glepnir/lspsaga.nvim'             -- improve lsp like rename and diagnostic
    -- linter and formatter
    use {
        "jose-elias-alvarez/null-ls.nvim", -- lsp based format
        requires = { "nvim-lua/plenary.nvim" }
    }
    -- autocomplete
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'
    use 'dnlhc/glance.nvim'
    use 'L3MON4D3/LuaSnip'
    -- syntax highlight
    use 'nvim-treesitter/nvim-treesitter'
    use {
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
    }
    use 'RRethy/nvim-treesitter-textsubjects'
    use "kylechui/nvim-surround"
    use "windwp/nvim-autopairs"
    -- quick move using [ and ]
    use 'tummetott/unimpaired.nvim'
    -- multi cursors
    use 'mg979/vim-visual-multi'
    -- enable loading outside json configs
    use 'tamago324/nlsp-settings.nvim'

    use {
        'folke/trouble.nvim',
        requires = 'kyazdani42/nvim-web-devicons',
    }

    -- git
    use 'lewis6991/gitsigns.nvim'
    use 'akinsho/git-conflict.nvim'

    -- status line
    use {
        'nvim-lualine/lualine.nvim',
        requires = 'kyazdani42/nvim-web-devicons'
    }

    -- floating terminal
    use 'akinsho/toggleterm.nvim'

    -- fzf
    use { 'junegunn/fzf', run = './install --bin', }
    use { 'ibhagwan/fzf-lua',
        -- optional for icon support
        requires = { 'nvim-tree/nvim-web-devicons' }
    }
    use {
        'nvim-pack/nvim-spectre',
        requires = 'nvim-lua/plenary.nvim'
    }
    -- file telescope
    --use 'BurntSushi/ripgrep'
    --use {
    --    'nvim-telescope/telescope.nvim',
    --    requires = 'nvim-lua/plenary.nvim'
    --}

    use 'rmagatti/auto-session'
    --use 'mbbill/undotree'

    -- indent guide
    use 'lukas-reineke/indent-blankline.nvim'

    -- scroll bar
    use 'petertriho/nvim-scrollbar'

    -- comments toggle
    use 'numToStr/Comment.nvim'

    -- ascii image
    use 'samodostal/image.nvim'
end)
