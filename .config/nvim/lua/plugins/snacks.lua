local function picker(method, opts)
	return function()
		Snacks.picker[method](opts or {})
	end
end

return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 900,
	keys = {
		{ "<leader>fb", picker("buffers"), desc = "Buffers" },
		{ "<leader>fd", picker("diagnostics"), desc = "Diagnostics" },
		{ "<leader>ff", picker("files", { hidden = true, ignored = true }), desc = "Find files" },
		{ "<leader>fh", picker("help"), desc = "Help" },
		{ "<leader>fr", picker("recent"), desc = "Recent files" },
		{ "<leader>fR", picker("resume"), desc = "Resume picker" },
		{ "<leader>fw", picker("grep_word"), desc = "Search word under cursor" },
		{ "<leader>gl", picker("git_log"), desc = "Git log" },
		{ "<leader>gs", picker("git_status"), desc = "Git status" },
		{ "<leader>lg", picker("grep", { hidden = true, ignored = true }), desc = "Live grep" },
		{
			"<c-b>",
			function()
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},
	},
	opts = {
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true },
		indent = { enabled = true },
		input = { enabled = true },
		notifier = { enabled = true },
		picker = {
			enabled = true,
			sources = {
				explorer = {
					hidden = true,
					ignored = true,
					exclude = { ".git", ".next", "node_modules" },
					win = {
						list = {
							keys = {
								["<c-b>"] = "close",
							},
						},
					},
				},
			},
		},
		quickfile = { enabled = true },
		scope = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true, debounce = 300 },
	},
}
