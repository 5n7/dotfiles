return {
	"stevearc/oil.nvim",
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
	},
	opts = {
		view_options = {
			show_hidden = true,
		},
		skip_confirm_for_simple_edits = true,
		keymaps = {
			["q"] = "actions.close",
		},
	},
}
