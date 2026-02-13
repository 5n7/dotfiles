return {
	"akinsho/bufferline.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	event = "VeryLazy",
	opts = {
		options = {
			style_preset = { 2, 4 }, -- minimal, no_italic
			separator_style = "slant",
			indicator = { style = "underline" },
			diagnostics = "nvim_lsp",
			show_buffer_close_icons = false,
			show_close_icon = false,
			offsets = {
				{
					filetype = "snacks_layout_box",
					text = "",
					highlight = "Directory",
				},
			},
		},
	},
}
