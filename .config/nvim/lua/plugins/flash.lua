return {
	"folke/flash.nvim",
	event = "VeryLazy",
	keys = {
		{
			"s",
			function()
				require("flash").jump()
			end,
			mode = { "n", "x", "o" },
			desc = "Flash jump",
		},
		{
			"S",
			function()
				require("flash").treesitter()
			end,
			-- Takes precedence over nvim-surround's visual S, which is intentional.
			mode = { "n", "x", "o" },
			desc = "Flash treesitter",
		},
	},
	opts = {},
}
