return {
	"akinsho/bufferline.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	event = "VeryLazy",
	opts = {
		options = {
			diagnostics = "nvim_lsp",
			indicator = { style = "underline" },
			offsets = {
				{
					filetype = "snacks_layout_box",
					text = "",
					highlight = "Directory",
				},
			},
			separator_style = "slant",
			show_buffer_close_icons = false,
			show_close_icon = false,
			style_preset = { 2, 4 }, -- minimal, no_italic
		},
	},
}
