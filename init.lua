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
--vim.opt.clipboard = "unnamed"
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
vim.api.nvim_create_autocmd("User",{
    pattern = "LazyDone",
    callback = function ()
        if require("lazy.status").updates() == true then
            require("lazy").update({wait = true})
            vim.cmd("q")
        end
    end,
})
            --require("lazy.status").updates,
vim.keymap.set({ "i", "c" }, "''", "''<left>", MyOpts)
vim.keymap.set({ "i", "c" }, '""', '""<left>', MyOpts)
vim.keymap.set({ "i", "c" }, "{", "{}<left>", MyOpts)
vim.keymap.set({ "i", "c" }, "[", "[]<left>", MyOpts)
vim.keymap.set({ "i", "c" }, "(", "()<left>", MyOpts)
vim.api.nvim_set_keymap("n", "<C-l>", "<C-W>l", {silent = true})
vim.api.nvim_set_keymap("n", "<C-h>", "<C-W>h", {silent = true})
vim.api.nvim_set_keymap("n", "<C-j>", "<C-W>j", {silent = true})
vim.api.nvim_set_keymap("n", "<C-k>", "<C-W>k", {silent = true})
vim.api.nvim_set_keymap("n", "<leader>v", "<C-W>v", {silent = true})
vim.api.nvim_set_keymap("n", "<leader>e", ":Explore<Enter>", {silent = true})
vim.api.nvim_set_keymap("n", "<leader>h", ":noh<CR>", {silent = true})
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', {silent = true})

vim.keymap.set("n", "<C-d>", "<C-d>zz", MyOpts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", MyOpts)

--vs-like alt line movement
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", MyOpts)
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", MyOpts)
vim.keymap.set("n", "<A-k>", ":m .-2<CR>=<CR>", MyOpts)
vim.keymap.set("n", "<A-j>", ":m .+1<CR>=<CR>", MyOpts)
vim.keymap.set("i", "<A-k>", "<esc>:m .-2<CR>=<CR>i", MyOpts)
vim.keymap.set("i", "<A-j>", "<esc>:m .+1<CR>=<CR>i", MyOpts)
-- obsidian-like copy paste
vim.keymap.set("i", "<C-v>", '<esc>"*pi', MyOpts)
vim.keymap.set("i", "<C-c>", '<esc>"*yya', MyOpts)
vim.keymap.set("n", "<C-c>", '"*yy', MyOpts)
vim.keymap.set("v", "<C-c>", '"*y', MyOpts)

--the i have no idea what it does corner
vim.keymap.set("n", "<leader>z", "'z", MyOpts) --no idea why
vim.keymap.set("n", "Q", "<nop>") --no idea what Q does
vim.cmd.highlight({ "Error", "guibg=red" })       --UNTESTED
vim.cmd.highlight({ "link", "Warning", "Error" }) --UNTESTED
--vim.cmd([[ same but in one line mode 
--  highlight Error guibg=red
--  highlight link Warning Error
--]])

pcall(require("lualine").setup)
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function ()
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#ffee00" })
        vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
    end
})
pcall(vim.cmd.colorscheme("kanagawa-wave"))
