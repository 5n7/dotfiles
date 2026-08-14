return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		-- Eager: its setup is what puts mason/bin on PATH, and that is the only
		-- place the servers enabled from init.lua exist. Deferring it would race
		-- the FileType-driven LSP start for a file named on the command line.
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
		},
		-- Only installs missing servers, so it can wait until the UI is up and
		-- keep mason-registry off the startup path.
		event = "VeryLazy",
		opts = {
			ensure_installed = { "gopls", "lua_ls", "vtsls" },
			-- Server configs live in ./lsp/*.lua and are enabled from init.lua.
			-- Auto-enabling would also enable leftover Mason packages that have no
			-- config here, since nvim-lspconfig is not installed.
			automatic_enable = false,
		},
	},
}
