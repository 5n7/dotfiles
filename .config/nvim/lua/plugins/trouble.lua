return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	keys = {
		{ "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
		{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
	},
	opts = {},
}
