local ensure = {
	"bash",
	"css",
	"cue",
	"diff",
	"go",
	"gomod",
	"gosum",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"nix",
	"proto",
	"regex",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		opts = {
			install_dir = vim.fn.stdpath("data") .. "/site",
		},
		config = function(_, opts)
			local ts = require("nvim-treesitter")
			ts.setup(opts)

			vim.api.nvim_create_autocmd("User", {
				pattern = "VeryLazy",
				once = true,
				callback = function()
					if vim.fn.executable("tree-sitter") ~= 1 then
						vim.notify(
							"nvim-treesitter: 'tree-sitter' CLI is not in PATH. It comes from modules/home/packages.nix, so re-run `darwin-rebuild switch`, then :TSUpdate.",
							vim.log.levels.WARN
						)
						return
					end

					ts.install(ensure, { summary = true, max_jobs = 2 })
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufNewFile", "BufReadPost" },
		opts = {
			max_lines = 3,
			multiline_threshold = 8,
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "BufReadPost",
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = {
						["@parameter.outer"] = "v",
						["@function.outer"] = "V",
						["@class.outer"] = "<C-v>",
					},
				},
				move = { set_jumps = true },
			})

			local select_to = require("nvim-treesitter-textobjects.select").select_textobject
			local move = require("nvim-treesitter-textobjects.move")
			local swap = require("nvim-treesitter-textobjects.swap")

			local textobjects = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
			}
			for key, capture in pairs(textobjects) do
				vim.keymap.set({ "x", "o" }, key, function()
					select_to(capture, "textobjects")
				end, { desc = "Select " .. capture })
			end

			local goto_next = move.goto_next_start
			local goto_prev = move.goto_previous_start
			vim.keymap.set({ "n", "x", "o" }, "]f", function()
				goto_next("@function.outer", "textobjects")
			end, { desc = "Next function" })
			vim.keymap.set({ "n", "x", "o" }, "[f", function()
				goto_prev("@function.outer", "textobjects")
			end, { desc = "Prev function" })
			-- ]c / [c stay on diff navigation inside diff windows (diffview, :diffthis).
			vim.keymap.set({ "n", "x", "o" }, "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					goto_next("@class.outer", "textobjects")
				end
			end, { desc = "Next class" })
			vim.keymap.set({ "n", "x", "o" }, "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					goto_prev("@class.outer", "textobjects")
				end
			end, { desc = "Prev class" })
			vim.keymap.set({ "n", "x", "o" }, "]a", function()
				goto_next("@parameter.outer", "textobjects")
			end, { desc = "Next argument" })
			vim.keymap.set({ "n", "x", "o" }, "[a", function()
				goto_prev("@parameter.outer", "textobjects")
			end, { desc = "Prev argument" })

			vim.keymap.set("n", "<leader>sa", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "Swap next argument" })
			vim.keymap.set("n", "<leader>sA", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "Swap prev argument" })
		end,
	},
}
