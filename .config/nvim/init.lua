vim.loader.enable()

for _, provider in ipairs({ "node", "perl", "python3", "ruby" }) do
	vim.g["loaded_" .. provider .. "_provider"] = 0
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.cursorline = true
vim.opt.number = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.smoothscroll = true
vim.opt.winborder = "rounded"

-- Experimental in 0.12: long messages collapse behind a `[+x]` indicator instead
-- of a |hit-enter| prompt. They stay in the cmdline because the "msg" float only
-- pays off at 'cmdheight' 0. pcall because this private module already moved once
-- (vim._extui) on the unstable channel, and a rename must fall back to the legacy UI.
pcall(function()
	require("vim._core.ui2").enable({ msg = { targets = "cmd" } })
end)

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- foldmethod switches to expr only in windows where treesitter started; see autocmds.lua.
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldtext = ""

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.updatetime = 200
vim.opt.whichwrap:append("h,l")

vim.diagnostic.config({
	float = { source = "if_many" },
	severity_sort = true,
	virtual_text = { spacing = 2, source = "if_many" },
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("autocmds")
require("keymaps")
require("plugins")

vim.lsp.enable({ "bashls", "buf_ls", "gopls", "jsonls", "lua_ls", "nixd", "rust_analyzer", "vtsls", "yamlls" })
