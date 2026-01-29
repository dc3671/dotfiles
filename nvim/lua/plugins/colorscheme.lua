-- Colorscheme plugins

return {
    -- OneDark theme (active)
    {
        "navarasu/onedark.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("set background=dark")
            require('onedark').setup {
                style = 'warmer',
                code_style = {
                    comments = 'none',
                }
            }
            require('onedark').load()
        end,
    },
}
