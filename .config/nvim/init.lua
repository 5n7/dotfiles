vim.loader.enable()

for _, provider in ipairs({ "ruby", "perl", "node", "python3" }) do
	vim.g["loaded_" .. provider .. "_provider"] = 0
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- UI
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.smoothscroll = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Indent
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

-- Folding
vim.opt.foldmethod = "manual"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldtext = ""

-- Split
vim.opt.splitright = true
vim.opt.splitbelow = true

-- System
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.undofile = true
vim.opt.updatetime = 200
vim.opt.timeoutlen = 300
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.whichwrap:append("h,l")

-- Diagnostics
vim.diagnostic.config({
	signs = true,
	underline = true,
	severity_sort = true,
	virtual_text = { spacing = 2, source = "if_many" },
	float = { border = "rounded", source = "if_many" },
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
vim.lsp.enable({ "gopls", "lua_ls", "vtsls" })
