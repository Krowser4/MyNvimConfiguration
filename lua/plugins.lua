local weInInit = vim.cmd("echo expand('%:t')") == [[C:\Users\Gabriel\AppData\Local\nvim\plugins.lua]]
return {
    "morhetz/gruvbox",
    {
        "nvim-tree/nvim-web-devicons",
        enabled = vim.g.have_nerd_font,
    },
    {
        "rebelot/kanagawa.nvim",
        opts = {
            commentStyle = { italic = false },
            keywordStyle = { italic = false },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter.install").prefer_git = false
            require("nvim-treesitter.configs").setup({
                -- indent = {enable = true},
                ensure_installed = {
                    --Install parsers in Neovim via :TSInstall c, :TSInstall cpp
                    "luadoc",
                    "markdown",
                    "c",
                    "cpp",
                    "lua",
                    "vim",
                    "vimdoc",
                    "query",
                    "cpp",
                    "python",
                    "gdscript",
                    "godot_resource",
                    "gdshader",
                },
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gss",
                        node_incremental = "gsi",
                        scope_incremental = "gsc",
                        node_decremental = "gsd",
                    },
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                        },
                        selection_modes = {
                            ["@parameter.outer"] = "v",
                            ["@function.outer"] = "V",
                            ["@class.outer"] = "<c-v>",
                        },
                        include_surrounding_whitespace = true,
                    },
                },
            })
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "nvim-telescope/telescope-ui-select.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
        },
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                },
            })
            pcall(require("telescope").load_extension, "ui-select")
            pcall(require("telescope").load_extension, "fzf")
            local builtin = require("telescope.builtin")
            --vim.keymap.set('n', '<C-p>', builtin.git_files, {}) --for git files
            vim.keymap.set("n", "<leader>sf", builtin.find_files)
            vim.keymap.set("n", "<leader>/", function()
                builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                    winblend = 10,
                    previewer = false,
                }))
            end, { desc = "[/] Fuzzily search in current buffer" })
            vim.keymap.set("n", "<leader>sn", function()
                builtin.find_files({ cwd = vim.fn.stdpath("config") })
            end, { desc = "[S]earch [N]eovim files" })
            if vim.fn.executable("make") == 1 then
                --if (io.popen("rg --version")):read("*a") ~= "" then --old check to see if make is installed
                vim.keymap.set("n", "<leader>sw", function()
                    builtin.grep_string({ search = vim.fn.input("Grep > ") })
                end)
                vim.keymap.set("n", "<leader>s/", function()
                    builtin.live_grep({
                        grep_open_files = true,
                        prompt_title = "Live Grep in Open Files",
                    })
                end, { desc = "[S]earch [/] in Open Files" })
            end
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local onAttach = function()
                vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0 })
                vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { buffer = 0 })
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = 0 })
                vim.keymap.set("n", "<leader>En", vim.diagnostic.goto_next, { buffer = 0 })
                vim.keymap.set("n", "<leader>Ep", vim.diagnostic.goto_prev, { buffer = 0 })
                vim.keymap.set("n", "<leader>El", "<cmd>Telescope diagnostics<CR>", { buffer = 0 })
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = 0 })
                vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = 0 })
            end
            lspconfig.gdscript.setup({
                capabilities = capabilities,
                on_attach = onAttach,
            })
            lspconfig.gdshader_lsp.setup({
                capabilities = capabilities,
                on_attach = onAttach,
            })
            lspconfig.pyright.setup({
                capabilities = capabilities,
                on_attach = onAttach,
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "off",
                        },
                    },
                },
            })
            lspconfig.clangd.setup({
                capabilities = capabilities,
                on_attach = onAttach,
                cmd = { "clangd", "--background-index", "--clang-tidy", "--log=verbose" },
                init_options = {
                    fallback_flags = { "-std=c++17" },
                },
            })
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                on_attach = onAttach,
                on_init = function(client)
                    if client.workspace_folders then
                        local path = client.workspace_folders[1].name
                        if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
                            return
                        end
                    else
                        print("No workspace found")
                    end
                    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                        runtime = {
                            version = "LuaJIT",
                        },
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                vim.env.VIMRUNTIME,
                                -- Depending on the usage, you might want to add additional paths here.
                                "${3rd}/luv/library",
                                "${3rd}/busted/library",
                            },
                            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                            --library = vim.api.nvim_get_runtime_file("", true)
                        },
                    })
                end,
                settings = {
                    Lua = {
                        diagnostics = weInInit and { disable = { "missing-fields" } } or {}, --UNTESTED
                        --diagnostics = { disable = { 'missing-fields' }, }, --original
                    },
                },
            })
        end,
    },
    {
        "nvimtools/none-ls.nvim",
        dependencies = {
            "nvimtools/none-ls-extras.nvim",
            "nvim-lua/plenary.nvim",
        },
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                event = "VeryLazy",
                should_attach = function(bufnr)
                    return vim.api.nvim_buf_get_name(bufnr):match("(.*).lua$")
                        or vim.api.nvim_buf_get_name(bufnr):match("(.*).py$")
                    -- or vim.api.nvim_buf_get_name(bufnr):match("(.*).txt$")
                end,
                sources = {
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.black,
                    null_ls.builtins.formatting.isort,
                    null_ls.builtins.completion.spell, --no idea what this is
                    require("none-ls.diagnostics.eslint"), --no idea what this is
                },
            })
            vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
        end,
    },
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                build = function ()
                    return "make install_jsregexp"
                end,
                dependencies = {
                    "saadparwaiz1/cmp_luasnip",
                    "rafamadriz/friendly-snippets",
                },
            },
            {
                "hrsh7th/cmp-cmdline",
                dependencies = {
                    "hrsh7th/cmp-path",
                    "hrsh7th/cmp-buffer",
                },
            },
            "hrsh7th/cmp-nvim-lsp",
            "onsails/lspkind.nvim",
        },
        config = function()
            local cmp = require("cmp")
            require("luasnip.loaders.from_vscode").lazy_load()
            cmp.setup({
                formatting = {
                    format = require("lspkind").cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,
                        show_labelDetails = false,
                        ellipsis_char = "...",
                    }),
                },
                completion = { completeopt = "menu, menuone, noinsert" }, -- no idea what it does
                window = {
                    completion = cmp.config.window.bordered(),
                    -- documentation = cmp.config.window.bordered(),
                    documentation = false,
                },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },

                mapping = cmp.mapping.preset.insert({
                    ["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
                    ["<C-y>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
                    ["<C-n"] = cmp.mapping.select_next_item(),
                    -- ["<C-h"] = cmp.mapping.jump(),
                    -- ["<C-l"] = cmp.mapping.jump(-1),
                }),
                -- mapping = cmp.mapping.preset.insert(),

                -- old one
                -- sources = cmp.config.sources({
                --     { name = "nvim_lsp" },
                --     { name = "luasnip" },
                -- }, {
                --     {
                --         name = "lazydev",
                --         group_index = 0,
                --     },
                --     { name = "buffer" },
                --     -- { name = "path" },
                -- }),

                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                    {
                        name = "lazydev",
                        group_index = 0,
                    },
                }),
            })
            -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
            -- Set configuration for specific filetype.
            --[[ cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'git' },
        }, {
          { name = 'buffer' },
        })
      })
      require("cmp_git").setup() ]]
            --
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                },
            })
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                -- mapping = cmp.mapping.preset.cmdline({
                -- 	["<C-i>"] = cmp.mapping(function(fallback)
                -- 		if cmp.visible() then
                -- 			-- cmp.complete()
                -- 			cmp.confirm({select = false})
                -- 		else
                -- 			fallback()
                -- 		end
                -- 	end),
                -- }),
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    { name = "cmdline" },
                }),
                matching = { disallow_symbol_nonprefix_matching = false },
            })
                    -- ["<C-h"] = cmp.mapping.jump(),
                    -- ["<C-l"] = cmp.mapping.jump(-1),
            vim.keymap.set({"i", "s"}, "<C-l>", function()
                if require("luasnip").expand_or_jumpable() then
                    require("luasnip").expand_or_jump()
                end
            end)
            vim.keymap.set({"i", "s"}, "<C-h>", function()
                if require("luasnip").jumpable(-1) then
                    require("luasnip").jump(-1)
                end
            end)
        end,
    },
    {
        "rmagatti/auto-session",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            SessionName = "SavedSession"
            SessionLocation = ""
            SessionExists = false
            require("auto-session").setup({
                session_lens = { mappings = {} },
                enabled = false,
                suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
                log_level = "error",
            })
            vim.api.nvim_create_user_command("Save", function()
                require("auto-session").SaveSessionToDir(SessionLocation, SessionName)
                SessionExists = true
            end, {})
            vim.api.nvim_create_user_command("Exit", function()
                SessionExists = false
                vim.cmd("wqa")
            end, {})
            vim.api.nvim_create_autocmd("User", {
                pattern = "LazyDone",
                nested = true,
                callback = function()
                    SessionLocation = vim.fn.getcwd() .. "nvim\\"
                    local saveFile = io.open(SessionLocation .. "\\" .. SessionName .. ".vim", "r")
                    if saveFile then
                        SessionExists = true
                        saveFile:close()
                        require("auto-session").RestoreSessionFromDir(SessionLocation.."\\", SessionName, false)
                    end
                end,
            })
            vim.api.nvim_create_autocmd("VimLeave", {
                callback = function()
                    if SessionExists then
                        require("auto-session").SaveSessionToDir(SessionLocation.."\\", SessionName, false)
                    end
                end,
            })
        end,
    },
    {
        "stevearc/oil.nvim",
        ---@module 'oil'
        ---@type oil.SetupOpts
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
        config = function()
            require("oil").setup({
                -- default_file_explorer = false,
                use_default_keymaps = false,
            })
            vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>")
            vim.keymap.set("n", "<leader>r", function()
                if vim.bo.filetype == "oil" then
                    require("oil.actions").refresh.callback()
                end
            end)
            vim.keymap.set("n", "-", function()
                if vim.bo.filetype == "oil" then
                    require("oil.actions").parent.callback()
                end
            end)
            vim.keymap.set("n", "<CR>", function()
                if vim.bo.filetype == "oil" then
                    require("oil.actions").select.callback()
                end
            end)
        end,
    },
}
