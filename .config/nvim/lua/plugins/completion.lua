return {
	"saghen/blink.cmp",
	version = "1.*",
	dependencies = {
		"folke/lazydev.nvim",
	},
	event = "InsertEnter",
	opts = {
		keymap = { preset = "default" },
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		signature = { enabled = true },
	},
}
