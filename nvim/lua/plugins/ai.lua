-- AI tools plugins

return {
    -- CopilotChat
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = { "github/copilot.vim", "nvim-lua/plenary.nvim" },
        config = function()
            require("CopilotChat").setup {
                model = 'claude-opus-4.5',
                mappings = {
                    reset = {
                        normal = "<leader>rr",
                        insert = "<leader>rr"
                    }
                },
                selection = function(source)
                    local select = require("CopilotChat.select")
                    return select.visual(source) or select.buffer(source)
                end
            }
        end,
    },
}
