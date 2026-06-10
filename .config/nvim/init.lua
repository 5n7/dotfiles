vim.loader.enable()

for _, provider in ipairs({ "node", "perl", "python3", "ruby" }) do
	vim.g["loaded_" .. provider .. "_provider"] = 0
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- UI
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.smoothscroll = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Indent
vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Folding
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "manual"
vim.opt.foldtext = ""

-- Split
vim.opt.splitbelow = true
vim.opt.splitright = true

-- System
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.mouse = "a"
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.updatetime = 200
vim.opt.whichwrap:append("h,l")

-- Diagnostics
vim.diagnostic.config({
	float = { border = "rounded", source = "if_many" },
	severity_sort = true,
	signs = true,
	underline = true,
	virtual_text = { spacing = 2, source = "if_many" },
})

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("autocmds")
require("keymaps")
require("plugins")

-- Nvim 0.11+ native LSP
vim.lsp.enable({ "buf_ls", "gopls", "lua_ls", "vtsls" })
