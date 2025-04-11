--https://neovim.io/doc/user/lua-guide.html
--note: LspreStart, :LspStart :LspStop
--requisites:
--  install ripgrep
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

SessionLocation = vim.fn.getcwd().."\\.nvim\\"
SessionName = "SavedSession"
SessionExists = false
SaveFileEarly = io.open(SessionLocation .. "\\" .. SessionName .. ".vim", "r")
StartingFile = ""
MyOpts = { noremap = true, silent = true }

vim.lsp.log.set_level(vim.log.levels.OFF)
-- vim.lsp.log.set_level(vim.log.levels.ERROR)

vim.opt.ignorecase = true

vim.opt.rtp:prepend(lazypath)
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.opt.number = true
vim.opt.relativenumber = true

-- vim.opt.virtualedit = "block"
-- vim.opt.termguicolors = true
vim.opt.termguicolors = false
vim.opt.showmode = false
vim.opt.wrap = false
-- vim.opt.scrolloff = 999
vim.opt.guicursor = "a:block"
vim.opt.mouse = ""
vim.opt.list = true
vim.opt.listchars = { tab = "> ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.laststatus = 2
vim.g.have_nerd_font = true

-- vim.opt.hlsearch = false
vim.opt.incsearch = true
--vim.opt.clipboard = "unnamed"
vim.opt.modifiable = true
vim.opt.autochdir = true

-- vim.opt.shadafile = "NONE"
-- vim.opt.shadafile = SessionLocation .. "\\myShadaFile.shada"
-- vim.opt.undodir = SessionLocation
-- vim.opt.undofile = true

if SaveFileEarly then
    vim.opt.shadafile = SessionLocation .. "\\myShadaFile.shada"
    vim.opt.undodir = SessionLocation
    vim.opt.undofile = true
else
    vim.opt.shadafile = "NONE"
    vim.opt.undofile = false
    vim.opt.undodir = ""
end

vim.opt.swapfile = false
vim.opt.backup = false

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        StartingFile = vim.fn.getcwd()
        if require("lazy.status").has_updates then
            require("lazy").update({ show = false, })
        end
    end,
})

require("lazy").setup({
    spec = require("plugins"),
    install = { missing = true, colorscheme = { "industry" }, },
    checker = { enabled = true, notify = false, },
    change_detection = { notify = false, },
})

-- vim.keymap.set("n", "<leader>b", function()
--     local batchFile = vim.fn.findfile("build.bat", StartingFile .. "**")
--     if batchFile ~= "" then
--         print(batchFile)
--         vim.cmd("!cmd /c " .. batchFile)
--     else
--         print("No batch file found from: "..StartingFile)
--     end
-- end)

-- vim.keymap.set("n", "<leader>b", function()
--     local batchFile = vim.fn.findfile("build.bat", StartingFile .. "/**")
--     if batchFile ~= "" then
--         local batchFilePath = vim.fn.fnamemodify(batchFile, ":p:h")
--         -- print("Batch file found: " .. batchFile)
--         -- print("Switching to directory: " .. batchFilePath)
--         vim.cmd("cd " .. batchFilePath)
--         vim.cmd("!cmd /c build.bat")
--         vim.cmd("cd -")  -- Switch back to the original directory
--     else
--         print("No batch file found from: " .. StartingFile)
--     end
-- end)

vim.keymap.set("n", "<leader>b", function()
    local batchFileToRun = "build.bat"
    local batchFile = vim.fn.findfile(batchFileToRun, StartingFile .. "/**")
    if batchFile ~= "" then
        local batchFilePath = vim.fn.fnamemodify(batchFile, ":p:h")
        vim.cmd("cd " .. batchFilePath)
        vim.cmd("!cmd /c " .. batchFileToRun)
        vim.cmd("cd -")
    else
        print("No batch file found from: " .. StartingFile)
    end
end)

vim.keymap.set({ "i", "c", "v", "s" }, "''", "''<left>", MyOpts)
vim.keymap.set({ "i", "c", "v", "s" }, '""', '""<left>', MyOpts)
vim.keymap.set({ "i", "c", "v", "s" }, "{{", "{}<left>", MyOpts)
vim.keymap.set({ "i", "c", "v", "s" }, "[[", "[]<left>", MyOpts)
vim.keymap.set({ "i", "c", "v", "s" }, "((", "()<left>", MyOpts)
vim.keymap.set({ "i", "c", "v", "s" }, "{<leader>", "{} ", MyOpts)
vim.keymap.set({ "i", "c", "v", "s" }, "[<leader>", "[] ", MyOpts)
vim.keymap.set({ "i", "c", "v", "s" }, "(<leader>", "() ", MyOpts)
vim.api.nvim_set_keymap("n", "<C-l>", "<C-W>l", { silent = true })
vim.api.nvim_set_keymap("n", "<C-h>", "<C-W>h", { silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-W>j", { silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-W>k", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>v", "<C-W>v", { silent = true })
-- vim.api.nvim_set_keymap("n", "<leader>e", ":Explore<Enter>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>h", ":noh<CR>", { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { silent = true })
vim.keymap.set("x", "<leader>p", '"_dP', { silent = true })

--vs-like alt line movement
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", MyOpts)
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", MyOpts)
vim.keymap.set("n", "<A-k>", ":m .-2<CR>=<CR>", MyOpts)
vim.keymap.set("n", "<A-j>", ":m .+1<CR>=<CR>", MyOpts)
vim.keymap.set("i", "<A-k>", "<esc>:m .-2<CR>=<CR>i", MyOpts)
vim.keymap.set("i", "<A-j>", "<esc>:m .+1<CR>=<CR>i", MyOpts)

-- obsidian-like copy paste
vim.keymap.set("i", "<C-v>", '<esc>"*pa', MyOpts)
vim.keymap.set("i", "<C-c>", '<esc>"*yya', MyOpts)
vim.keymap.set("n", "<C-c>", '"*yy', MyOpts)
vim.keymap.set("v", "<C-c>", '"*y', MyOpts)

-- misc
vim.keymap.set("n", "<C-d>", "<C-d>zz", MyOpts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", MyOpts)
vim.keymap.set("n", "J", "mzJ`z", MyOpts)
vim.keymap.set("n", "<A-l>", "V=", MyOpts)
vim.keymap.set("i", "<A-l>", "<esc>V=a", MyOpts)
vim.keymap.set("n", "c,", "T,vt,di ", MyOpts)
-- vim.keymap.set({"n", "i", "v"}, "<RightAlt", "<C>", MyOpts) right alt dont work :c
-- vim.keymap.set("n", "c(,", "T(vt,di", MyOpts)
-- vim.keymap.set("n", "c),", "T,vt)di ", MyOpts)
-- vim.keymap.set("n", "c[,", "T[vt,di", MyOpts)
-- vim.keymap.set("n", "c],", "T,vt]di ", MyOpts)
-- vim.keymap.set("n", "c{,", "T{vt,di", MyOpts)
-- vim.keymap.set("n", "c},", "T,vt}di ", MyOpts)

--the "i have no idea what it does" corner
vim.keymap.set("n", "<leader>z", "'z", MyOpts) --no idea why
vim.keymap.set("n", "Q", "<nop>")              --no idea what Q does
vim.cmd.highlight({ "Error", "guibg=red" })
vim.cmd.highlight({ "link", "Warning", "Error" })
--vim.cmd([[ same but in one line mode
--  highlight Error guibg=red
--  highlight link Warning Error
--]])

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
})
--visual sugar
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.api.nvim_create_autocmd({"BufEnter", "WinEnter"}, {
    callback = function()
        vim.api.nvim_command('setlocal cursorline')
        vim.api.nvim_command('setlocal cursorlineopt=number')
    end,
})
vim.api.nvim_create_autocmd({"BufLeave", "WinLeave"}, {
    command = "setlocal nocursorline"
})
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        -- vim.api.nvim_set_hl(0, "LineNr", { fg = "#ffee00" })
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#707070" })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffee00" })
        vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
    end,
})
vim.api.nvim_create_autocmd("VimResized", {
    -- command = ":wincmd =<CR>",
    command = ":wincmd =",
})
pcall(require("lualine").setup)
pcall(vim.cmd.colorscheme("kanagawa-wave"))
