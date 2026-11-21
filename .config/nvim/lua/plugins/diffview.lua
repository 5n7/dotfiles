return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewFileHistory", "DiffviewOpen" },
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current)" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File history (all)" },
	},
	opts = {
		view = {
			merge_tool = {
				layout = "diff3_mixed",
			},
		},
	},
}
