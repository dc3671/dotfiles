-- Treesitter plugins and configuration

return {
    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        branch = 'master',
        lazy = false,
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "RRethy/nvim-treesitter-textsubjects",
            "hiphish/rainbow-delimiters.nvim",
            "theHamsta/nvim-treesitter-pairs",
        },
        config = function()
            -- Function to get the system architecture
            local function get_arch()
                local handle = io.popen("uname -m")
                if not handle then
                    return nil, "Failed to run 'uname -m'"
                end

                local arch = handle:read("*a")
                handle:close()

                -- Remove trailing newline characters
                arch = arch:gsub("^%s*(.-)%s*$", "%1")
                return arch
            end

            -- Get the architecture
            local architecture = get_arch()
            local is_x86 = architecture == "x86_64"
            local parser_dir
            if is_x86 then
                parser_dir = "~/.local/share/nvim/lazy/nvim-treesitter/parser_x86"
            else
                parser_dir = "~/.local/share/nvim/lazy/nvim-treesitter/parser_arm"
            end
            vim.opt.runtimepath:prepend(parser_dir)

            -- nvim-treesitter config
            require('nvim-treesitter.configs').setup {
                ensure_installed = { "c", "cpp", "lua", "python", "bash" },
                sync_install = true,
                ignore_install = {},
                parser_install_dir = parser_dir,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                textsubjects = {
                    enable = true,
                    keymaps = {
                        ['.'] = 'textsubjects-smart',
                        [';'] = 'textsubjects-container-outer',
                        ['i;'] = 'textsubjects-container-inner',
                    },
                },
                rainbow = {
                    enable = true,
                    extended_mode = true,
                    max_file_lines = 10000,
                },
                pairs = {
                    enable = true,
                    disable = {},
                    highlight_pair_events = { "CursorMoved" },
                    highlight_self = false,
                    goto_right_end = false,
                    fallback_cmd_normal = "call matchit#Match_wrapper('',1,'n')",
                    keymaps = {
                        goto_partner = "<leader>%",
                        delete_balanced = "X",
                    },
                    delete_balanced = {
                        only_on_first_char = false,
                        fallback_cmd_normal = nil,
                        longest_partner = false,
                    }
                }
            }
        end,
    },

    -- Treesitter textobjects
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = "nvim-treesitter/nvim-treesitter",
    },

    -- Treesitter textsubjects
    "RRethy/nvim-treesitter-textsubjects",

    -- Rainbow delimiters
    "hiphish/rainbow-delimiters.nvim",

    -- Treesitter pairs
    "theHamsta/nvim-treesitter-pairs",
}
