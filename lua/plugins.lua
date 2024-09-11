local weInInit = vim.cmd("echo expand('%:t')") == [[C:\Users\Gabriel\AppData\Local\nvim\plugins.lua]]
return {
    "nvim-tree/nvim-web-devicons",
    "rebelot/kanagawa.nvim",
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter.configs").setup({

                ensure_installed = {
                    "c",
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
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
        },
        config = function()
            require("telescope").setup()
            pcall(require("telescope").load_extension, "fzf")
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>sf", builtin.find_files)
            --vim.keymap.set('n', '<C-p>', builtin.git_files, {}) --for git files
            print()
            if (io.popen("rg --version")):read("*a") ~= "" then
                vim.keymap.set("n", "<leader>sw", function()
                    builtin.grep_string({ search = vim.fn.input("Grep > ") })
                end)
            end
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local onAttach = function ()
                vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer = 0})
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, {buffer = 0})
                vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, {buffer = 0})
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {buffer = 0})
                vim.keymap.set("n", "<leader>En", vim.diagnostic.goto_next, {buffer = 0})
                vim.keymap.set("n", "<leader>Ep", vim.diagnostic.goto_prev, {buffer = 0})
                vim.keymap.set("n", "<leader>El", "<cmd>Telescope diagnostics<CR>", {buffer = 0})
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {buffer = 0})
            end
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
        dependencies = { "nvimtools/none-ls-extras.nvim" },
        config = function()
            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.black,
                    null_ls.builtins.formatting.isort,
                    null_ls.builtins.completion.spell, --no idea what this is
                    require("none-ls.diagnostics.eslint"), --no idea what this is
                },
            })
            --vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {}) 
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
                dependencies = {
                    "saadparwaiz1/cmp_luasnip",
                },
            },{
                "hrsh7th/cmp-cmdline",
                dependencies = {
                    "hrsh7th/cmp-path",
                    "hrsh7th/cmp-buffer",
                },
            },
            "rafamadriz/friendly-snippets",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local cmp = require("cmp")
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                },{
                    { name = "buffer" },
                    { name = 'path' },
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
            require("cmp_git").setup() ]]-- 
            cmp.setup.cmdline({'/', '?'}, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                }),
                matching = { disallow_symbol_nonprefix_matching = false }
            })
        end,
    },
}
