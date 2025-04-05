return require("lazy").setup({
	{
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			require("catppuccin").setup({
				integrations = {
					hop = true,
				},
			})
			vim.cmd.colorscheme("catppuccin")
		end,
		init = function()
			vim.g.catppuccin_flavour = "mocha"
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = { "MunifTanjim/nui.nvim", "kyazdani42/nvim-web-devicons", "nvim-lua/plenary.nvim" },
		config = function()
			require("neo-tree").setup({
				filesystem = {
					filtered_items = {
						hide_dotfiles = false,
						hide_gitignored = false,
						always_show = { ".envrc" },
					},
				},
				window = {
					mappings = {
						["<c-b>"] = "close_window",
					},
				},
			})
		end,
		init = function()
			vim.keymap.set("n", "<c-b>", "<cmd>Neotree reveal=true toggle=true<cr>")

			vim.g.neo_tree_remove_legacy_commands = true
		end,
	},
})
