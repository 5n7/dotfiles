return {
	"stevearc/oil.nvim",
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
	},
	-- No snacks.rename here: lsp_file_methods already sends workspace/willRenameFiles,
	-- and both would apply the same edit.
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
