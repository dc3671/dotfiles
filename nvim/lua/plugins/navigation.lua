-- Navigation plugins

return {
    -- Nvim-tree file explorer
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            local function on_attach(bufnr)
                local api = require('nvim-tree.api')
                local function opts(desc)
                    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end
                api.config.mappings.default_on_attach(bufnr)
                vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer, opts('Open: In Place'))
                vim.keymap.del('n', '<C-e>', { buffer = bufnr })
            end

            require("nvim-tree").setup {
                on_attach = on_attach,
                reload_on_bufenter = true,
                update_focused_file = { enable = true },
                view = {
                    width = 30,
                    preserve_window_proportions = true,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = true,
                },
            }
        end,
    },

    -- Aerial code outline
    {
        "stevearc/aerial.nvim",
        branch = "nvim-0.11",
        config = function()
            require("aerial").setup {}
        end,
    },

    -- FZF
    {
        "junegunn/fzf",
        build = "./install --all --no-update-rc",
    },

    -- FZF Lua wrapper
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            -- Two upstream cwd holes: utils.cwd() asserts when the process cwd is
            -- deleted, and provider-set cwd (git/oldfiles/lsp) skips the fs_stat
            -- check in normalize_opts, hitting jobstart as E475. Patch both hooks.
            local uv = vim.uv or vim.loop
            local function isdir(dir)
                return type(dir) == "string" and #dir > 0
                    and vim.fn.isdirectory(vim.fn.expand(dir)) == 1
            end
            local function repair_cwd()
                if isdir(uv.cwd()) then return end
                -- expand("%:p:h") yields "." for an unnamed buffer, insist on absolute
                local buf = vim.fn.expand("%:p:h")
                local dir = (vim.startswith(buf, "/") and isdir(buf)) and buf or vim.env.HOME
                vim.notify("fzf-lua: cwd is gone, cd " .. dir, vim.log.levels.WARN)
                vim.cmd.cd(vim.fn.fnameescape(dir))
            end

            local config = require("fzf-lua.config")
            local normalize_opts = config.normalize_opts
            config.normalize_opts = function(...)
                repair_cwd()
                return normalize_opts(...)
            end

            local function drop_bad_cwd(opts)
                repair_cwd()
                if type(opts) == "table" and opts.cwd ~= nil and not isdir(opts.cwd) then
                    vim.notify(("fzf-lua: invalid cwd '%s', using %s")
                        :format(tostring(opts.cwd), uv.cwd()), vim.log.levels.WARN)
                    opts.cwd = nil
                end
                return opts
            end

            -- fzf_exec/fzf_live serialize cwd into the multiprocess child cmd before
            -- core.fzf runs, so sanitize there too; core.fzf is the backstop.
            local core = require("fzf-lua.core")
            for _, fn in ipairs({ "fzf_exec", "fzf_live", "fzf" }) do
                local orig = core[fn]
                core[fn] = function(contents, opts)
                    return orig(contents, drop_bad_cwd(opts))
                end
            end

            require("fzf-lua").setup {
                winopts = { preview = { flip_columns = 150 } },
                fzf_opts = { ['--layout'] = 'default' },
                files = {
                    cmd     = "rg --files",
                    rg_opts = [[--color=never --files --hidden --follow --no-ignore -g "!.git" -g "!*.cubin.cpp*" -g "!*_cubin.cpp*"]], },
                git = { files = { cmd = 'git ls-files --exclude-standard -- ":!:*.cubin.cpp*" ":!:*_cubin.cpp"' } },
                grep = {
                    cmd     = "rg --column --line-number --no-heading --color=always --smart-case",
                    rg_opts = '--column --line-number --no-heading --color=always -g "!*.cubin.cpp*" -g "!*_cubin.cpp*" --smart-case --max-columns=4096 -e' }
            }
        end,
    },

    -- Spectre for search and replace across files
    {
        "nvim-pack/nvim-spectre",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require('spectre').setup { default = { find = { cmd = "rg" } } }
        end,
    },

    -- Telescope (commented)
    -- "BurntSushi/ripgrep",
    -- {
    --     "nvim-telescope/telescope.nvim",
    --     dependencies = "nvim-lua/plenary.nvim"
    -- },

    -- Symbols outline (commented)
    -- "simrat39/symbols-outline.nvim",

    -- Nvim-IDE (commented)
    -- "ldelossa/nvim-ide",
}
