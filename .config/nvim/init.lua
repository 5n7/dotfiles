vim.g.mapleader = " "

vim.opt.number = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

vim.opt.whichwrap:append("h")
vim.opt.whichwrap:append("l")

require("autocmds")
require("keymaps")
require("plugins")
