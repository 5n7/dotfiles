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
vim.opt.winborder = "rounded"

-- Experimental in 0.12: replaces the builtin message and cmdline presentation
-- layer. Long messages are collapsed with a `[+x]` spill indicator instead of a
-- |hit-enter| prompt, and :messages opens the pager as an ordinary buffer.
-- Messages stay in the cmdline ("cmd") rather than the ephemeral "msg" float,
-- which only pays off at 'cmdheight' == 0; here the cmdline is always visible,
-- so a second floating box would only duplicate it.
-- pcall because neovim is pinned to unstable and this private module already
-- moved once (vim._extui); a rename must degrade to the legacy UI, not error.
pcall(function()
	require("vim._core.ui2").enable({ msg = { targets = "cmd" } })
end)

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Indent
vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Folding
-- foldexpr is global, but foldmethod only switches to expr window-locally where
-- treesitter started; see autocmds.lua.
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "manual"
vim.opt.foldtext = ""

-- Split
vim.opt.splitbelow = true
vim.opt.splitright = true

-- System
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.updatetime = 200
vim.opt.whichwrap:append("h,l")

-- Diagnostics
vim.diagnostic.config({
	float = { source = "if_many" },
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
vim.lsp.enable({ "bashls", "buf_ls", "gopls", "jsonls", "lua_ls", "nixd", "vtsls", "yamlls" })

-- Capability-gated, so a no-op for servers without documentOnTypeFormattingProvider.
-- vtsls (";", "}", "\n") and lua_ls ("\n") advertise it; gopls and buf_ls do not.
vim.lsp.on_type_formatting.enable()
