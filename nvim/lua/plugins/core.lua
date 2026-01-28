-- Core dependency plugins

return {
    -- Plenary - lua utility functions
    "nvim-lua/plenary.nvim",

    -- NUI - UI components library
    "MunifTanjim/nui.nvim",

    -- Impatient - faster startup
    {
        "lewis6991/impatient.nvim",
        config = function()
            require("impatient")
        end,
    },

    -- Auto session
    {
        "rmagatti/auto-session",
        config = function()
            require("auto-session").setup {
                log_level = "error",
                auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
            }
        end,
    },

    -- Startup time profiler
    "dstein64/vim-startuptime",

    -- Undotree (commented)
    -- "mbbill/undotree",

    -- Remote SSH copy (commented)
    -- "ojroques/nvim-osc52",
}
