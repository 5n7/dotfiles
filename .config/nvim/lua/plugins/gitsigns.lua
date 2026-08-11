return {
	"lewis6991/gitsigns.nvim",
	event = "BufReadPre",
	opts = {
		current_line_blame = true,
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local map = function(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			end

			map("n", "]h", function()
				gs.nav_hunk("next")
			end, "Next hunk")
			map("n", "[h", function()
				gs.nav_hunk("prev")
			end, "Previous hunk")
			map("n", "<leader>hb", gs.blame_line, "Blame line")
			map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
			map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
			map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
			-- undo_stage_hunk is deprecated: stage_hunk on a staged sign unstages it.
			map("n", "<leader>hu", gs.stage_hunk, "Unstage hunk")
			map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
		end,
	},
}
