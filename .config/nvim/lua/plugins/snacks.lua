local exclude = { ".git", ".next", ".wt", "node_modules" }

local function picker(method, opts)
	return function()
		Snacks.picker[method](opts or {})
	end
end

return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 1000,
	keys = {
		{ "<leader><leader>", picker("buffers"), desc = "Select buffer" },
		{ "<leader>fb", picker("buffers"), desc = "Buffers" },
		{ "<leader>fd", picker("diagnostics"), desc = "Diagnostics" },
		{ "<leader>ff", picker("files"), desc = "Find files" },
		{ "<leader>fh", picker("help"), desc = "Help" },
		{ "<leader>fr", picker("recent"), desc = "Recent files" },
		{ "<leader>fR", picker("resume"), desc = "Resume picker" },
		{ "<leader>fw", picker("grep_word"), desc = "Search word under cursor" },
		{ "<leader>gl", picker("git_log"), desc = "Git log" },
		{ "<leader>gs", picker("git_status"), desc = "Git status" },
		{ "<leader>lg", picker("grep"), desc = "Live grep" },
		{
			"<leader>gy",
			function()
				Snacks.gitbrowse({
					open = function(url)
						vim.fn.setreg("+", url)
					end,
				})
			end,
			desc = "Copy GitHub link",
			mode = { "n", "v" },
		},
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
		lazygit = { enabled = false },
		notifier = { enabled = true },
		picker = {
			enabled = true,
			sources = {
				explorer = {
					hidden = true,
					ignored = true,
					exclude = exclude,
					win = {
						list = {
							keys = {
								["<c-b>"] = "close",
							},
						},
					},
				},
				files = {
					hidden = true,
					ignored = true,
					exclude = exclude,
				},
				-- ignored is left at its default here, unlike the pickers above:
				-- --no-ignore makes rg read the contents of build output and vendored
				-- trees rather than just list their paths, which is what gets expensive
				-- in a large workspace. <a-i> turns it on from inside the picker.
				grep = {
					hidden = true,
					exclude = exclude,
				},
			},
		},
		quickfile = { enabled = true },
		scope = { enabled = true },
		statuscolumn = { enabled = true },
		-- Each debounce window sends a documentHighlight request. Keep it long enough
		-- that cursor movement does not queue work behind a busy server.
		words = { enabled = true, debounce = 500 },
	},
	config = function(_, opts)
		require("snacks").setup(opts)
		-- Guard against broken treesitter queries crashing the picker
		-- (https://github.com/folke/snacks.nvim/issues/2694)
		local highlight = require("snacks.picker.util.highlight")
		local get_highlights = highlight.get_highlights
		highlight.get_highlights = function(...)
			local ok, ret = pcall(get_highlights, ...)
			return ok and ret or {}
		end
	end,
}
