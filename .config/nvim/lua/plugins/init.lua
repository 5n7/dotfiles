return require("lazy").setup({
	spec = {
		{ import = "plugins.bufferline" },
		{ import = "plugins.tokyonight" },
		{ import = "plugins.claudecode" },
		{ import = "plugins.completion" },
		{ import = "plugins.conform" },
		{ import = "plugins.flash" },
		{ import = "plugins.gitsigns" },
		{ import = "plugins.lint" },
		{ import = "plugins.lsp" },
		{ import = "plugins.neogit" },
		{ import = "plugins.lualine" },
		{ import = "plugins.oil" },
		{ import = "plugins.snacks" },
		{ import = "plugins.surround" },
		{ import = "plugins.treesitter" },
		{ import = "plugins.trouble" },
		{ import = "plugins.which-key" },
	},
	change_detection = {
		notify = false,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrw",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
