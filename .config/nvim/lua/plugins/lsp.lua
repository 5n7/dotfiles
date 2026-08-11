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
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
		},
		opts = {
			ensure_installed = { "gopls", "lua_ls", "vtsls" },
			-- Server configs live in ./lsp/*.lua and are enabled from init.lua.
			-- Auto-enabling would also enable leftover Mason packages that have no
			-- config here, since nvim-lspconfig is not installed.
			automatic_enable = false,
		},
	},
}
