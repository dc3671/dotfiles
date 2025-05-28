require("lazy").setup({
    -- Core plugins
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",

    -- IDE-like side panels
    --"ldelossa/nvim-ide",
    "nvim-tree/nvim-tree.lua",
    "stevearc/aerial.nvim",
    --"simrat39/symbols-outline.nvim",

    -- startup time optimise
    "dstein64/vim-startuptime",
    "lewis6991/impatient.nvim",

    -- buffer
    {
        "akinsho/bufferline.nvim",
        dependencies = "nvim-tree/nvim-web-devicons"
    },
    "moll/vim-bbye",     -- for more sensible delete buffer cmd

    -- themes (disabled other themes to optimize startup time)
    -- "sainnhe/sonokai",
    -- "tiagovla/tokyodark.nvim",
    -- "projekt0n/github-nvim-theme",
    "navarasu/onedark.nvim",
    -- { "catppuccin/nvim", name = "catppuccin" },
    -- { "sonph/onehalf", dir = "vim/" },
    -- "liuchengxu/space-vim-dark",
    -- "ahmedabdulrahman/aylin.vim",
    -- "rebelot/kanagawa.nvim",
    -- "NLKNguyen/papercolor-theme",
    -- "liuchengxu/space-vim-dark",
    "sainnhe/edge",
    -- "B4mbus/oxocarbon-lua.nvim",
    -- "Th3Whit3Wolf/one-nvim",

    -- package management
    "mason-org/mason.nvim",
    -- lsp
    "mason-org/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    --"glepnir/lspsaga.nvim",            -- improve lsp like rename and diagnostic
    -- linter and formatter
    -- {
    --     "jose-elias-alvarez/null-ls.nvim", -- lsp based format
    --     dependencies = { "nvim-lua/plenary.nvim" }
    -- },
    -- autocomplete
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    --"hrsh7th/cmp-vsnip",
    --"hrsh7th/vim-vsnip",
    "rafamadriz/friendly-snippets",

    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = { "github/copilot.vim", "nvim-lua/plenary.nvim" },
    },

    "dnlhc/glance.nvim",
    -- syntax highlight
    { "nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate" },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = "nvim-treesitter/nvim-treesitter",
    },
    "RRethy/nvim-treesitter-textsubjects",
    "kylechui/nvim-surround",
    "windwp/nvim-autopairs",
    "hiphish/rainbow-delimiters.nvim",
    "theHamsta/nvim-treesitter-pairs",
    -- quick move using [ and ]
    "tummetott/unimpaired.nvim",
    -- multi cursors
    "mg979/vim-visual-multi",
    -- enable loading outside json configs
    "tamago324/nlsp-settings.nvim",

    {
        "folke/trouble.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
    },

    -- git
    "lewis6991/gitsigns.nvim",
    "akinsho/git-conflict.nvim",

    -- status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = "nvim-tree/nvim-web-devicons"
    },

    -- floating terminal
    "akinsho/toggleterm.nvim",

    -- fzf
    {
        "junegunn/fzf",
        build = "./install --all --no-update-rc",
    },
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" }
    },
    {
        "nvim-pack/nvim-spectre",
        dependencies = "nvim-lua/plenary.nvim"
    },
    -- file telescope
    --"BurntSushi/ripgrep",
    --{
    --    "nvim-telescope/telescope.nvim",
    --    dependencies = "nvim-lua/plenary.nvim"
    --},

    "rmagatti/auto-session",
    --"mbbill/undotree",
    -- remote ssh copy without xclip
    -- "ojroques/nvim-osc52",

    -- indent guide
    "lukas-reineke/indent-blankline.nvim",

    -- scroll bar
    "petertriho/nvim-scrollbar",

    -- comments toggle
    "numToStr/Comment.nvim",

    -- ascii image
    "samodostal/image.nvim",
})
