local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "failed to clone lazy.nvim:\n", "errormsg" },
            { out,                            "warningmsg" },
            { "\npress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)
--vim.schedule(function()
--    vim.opt.cursorline = true
--	--vim.opt.cursorlineopt = "number"
--	vim.opt.cursorlineopt = "both"
--end)
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.virtualedit = "block"

vim.opt.guicursor = "a:block"
vim.opt.scrolloff = 10
vim.opt.wrap = false
vim.opt.incsearch = true
vim.opt.clipboard = "unnamedplus"
vim.opt.modifiable = true
vim.opt.autochdir = true

MyOpts = { noremap = true, silent = true }
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("lazy").setup({
    spec = require("plugins"),
    install = { missing = true, colorscheme = { "industry" } },
    checker = { enabled = true },
})
--vim.keymap.set({"n", "v", "i"}, '"', '', MyOpts)
--vim.keymap.set({"n", "v", "i"}, "'", "", MyOpts)
vim.keymap.set({ "i", "c" }, "''", "''<left>", MyOpts)
vim.keymap.set({ "i", "c" }, '""', '""<left>', MyOpts)
vim.keymap.set({ "i", "c" }, "{", "{}<left>", MyOpts)
vim.keymap.set({ "i", "c" }, "[", "[]<left>", MyOpts)
vim.keymap.set({ "i", "c" }, "(", "()<left>", MyOpts)

vim.keymap.set("v", "<A-k>", "<cmd>m '<-2<CR>gv=gv", MyOpts)
vim.keymap.set("v", "<A-j>", "<cmd>m '>+1<CR>gv=gv", MyOpts)
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<CR>=<CR>", MyOpts)
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<CR>=<CR>", MyOpts)
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<CR>=<CR>i", MyOpts)
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<CR>=<CR>i", MyOpts)

vim.api.nvim_set_keymap("n", "<C-l>", "<C-W>l", MyOpts)
vim.api.nvim_set_keymap("n", "<C-h>", "<C-W>h", MyOpts)
vim.api.nvim_set_keymap("n", "<C-j>", "<C-W>j", MyOpts)
vim.api.nvim_set_keymap("n", "<C-k>", "<C-W>k", MyOpts)
vim.api.nvim_set_keymap("n", "<C-v>", "<C-W>v", MyOpts)

vim.keymap.set("n", "<C-d>", "<C-d>zz", MyOpts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", MyOpts)

vim.api.nvim_set_keymap("n", "<leader>e", "<cmd>Explore<Enter>", MyOpts)
vim.api.nvim_set_keymap("n", "<leader>h", "<cmd>noh<CR>", MyOpts)
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', MyOpts)

--the i have no idea what it does corner
vim.keymap.set("n", "<leader>z", "'z", MyOpts) --no idea why
vim.keymap.set("n", "Q", "<nop>") --no idea what Q does
vim.cmd.highlight({ "Error", "guibg=red" })       --UNTESTED
vim.cmd.highlight({ "link", "Warning", "Error" }) --UNTESTED
--vim.cmd([[
--  highlight Error guibg=red
--  highlight link Warning Error
--]])

pcall(vim.cmd.colorscheme("kanagawa-wave"))
pcall(require("lualine").setup)
vim.api.nvim_set_hl(0, "LineNr", { fg = "#ffee00" })
vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
