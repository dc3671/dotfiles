local M = {}
function M.config()
    -- Function to get the system architecture
    function get_arch()
        -- Execute the 'uname -m' command to get machine hardware name
        local handle = io.popen("uname -m")
        if not handle then
            return nil, "Failed to run 'uname -m'"
        end

        -- Read the output of the command
        local arch = handle:read("*a")
        handle:close()

        -- Remove trailing newline characters from the output
        arch = arch:gsub("^%s*(.-)%s*$", "%1")

        return arch
    end

    -- Get the architecture
    local architecture, err = get_arch()
    local is_x86 = architecture == "x86_64"
    local parser_dir
    if is_x86 then
        parser_dir = "~/.local/share/nvim/lazy/nvim-treesitter/parser_x86"
    else
        parser_dir = "~/.local/share/nvim/lazy/nvim-treesitter/parser_arm"
    end
    vim.opt.runtimepath:prepend(parser_dir)

    -- nvim-treesitter config
    -- require('nvim-treesitter.install').update({ with_sync = true })
    require('nvim-treesitter.configs').setup {
        -- ensure_installed = "maintained", -- for installing all maintained parsers
        ensure_installed = { "c", "cpp", "lua", "python", "bash" }, -- for installing specific parsers
        sync_install = true,                                        -- install synchronously
        ignore_install = {},                                        -- parsers to not install
        parser_install_dir = parser_dir,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false, -- disable standard vim highlighting
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
            -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
            extended_mode = true,   -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
            max_file_lines = 10000, -- Do not enable for files with more than n lines, int
            -- colors = {}, -- table of hex strings
            -- termcolors = {} -- table of colour name strings
        },
        pairs = {
            enable = true,
            disable = {},
            -- e.g. {"CursorMoved"}, -- when to highlight the pairs, use {} to deactivate highlighting
            highlight_pair_events = { "CursorMoved" },
            -- whether to highlight also the part of the pair under cursor (or only the partner)
            highlight_self = false,
            -- whether to go to the end of the right partner or the beginning
            goto_right_end = false,
            -- What command to issue when we can't find a pair (e.g. "normal! %")
            fallback_cmd_normal = "call matchit#Match_wrapper('',1,'n')",
            keymaps = {
                goto_partner = "<leader>%",
                delete_balanced = "X",
            },
            delete_balanced = {
                only_on_first_char = false, -- whether to trigger balanced delete when on first character of a pair
                fallback_cmd_normal = nil,  -- fallback command when no pair found, can be nil
                longest_partner = false,    -- whether to delete the longest or the shortest pair when multiple found.
                -- E.g. whether to delete the angle bracket or whole tag in  <pair> </pair>
            }
        }
    }
end

return M
