return {
	"stevearc/oil.nvim",
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
	},
	opts = {
		keymaps = {
			["q"] = "actions.close",
		},
		skip_confirm_for_simple_edits = true,
		view_options = {
			show_hidden = true,
		},
	},
}
