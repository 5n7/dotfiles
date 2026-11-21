local exclude = { ".git", ".next", ".wt", "node_modules" }

local function picker(method)
	return function()
		Snacks.picker[method]()
	end
end

-- The Herdr app's terminals draw Kitty graphics with Unicode placeholders like
-- ghostty, but snacks.image cannot detect that: they don't answer XTVERSION (hence
-- SNACKS_GHOSTTY), take no file path in place of image data (hence SNACKS_SSH), and
-- report no pixel size, so a cell of the app's font (herdr-app/default.nix) at 2x
-- is assumed. snacks.image spreads a 72-dpi image pixel over 96/72 * scale screen
-- pixels, so a scale of 72/96 maps it to one and a diagram rendered at 2x shows at
-- its own size.
local function herdr_app(opts)
	vim.env.SNACKS_GHOSTTY = "1"
	vim.env.SNACKS_SSH = "1"
	opts.image.convert = {
		mermaid = function()
			local theme = vim.o.background == "light" and "neutral" or "dark"
			return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", "2" }
		end,
	}
	local terminal = require("snacks.image.terminal")
	local size = terminal.size
	terminal.size = function()
		local s = size()
		if s.cell_width == 0 then
			s.cell_width, s.cell_height = 16, 34
			s.width, s.height = s.columns * s.cell_width, s.rows * s.cell_height
		end
		s.scale = 72 / 96
		return s
	end
end

return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 1000,
	-- bigfile claims every path over its size threshold before the extension is
	-- consulted, and its filetype sticks: its handler restores `syntax` but not
	-- `filetype`, so gopls, treesitter and completion silently never attach.
	-- Generated Go is routinely over the threshold (merpay's .pb.go run 1MB to 7MB)
	-- and is the code most worth navigating, so it is exempt: the largest parses once
	-- in ~350ms and is never edited. A priority above bigfile's ".*" default of 0
	-- settles the filetype first. vim.filetype.add anchors patterns as `^..$` itself,
	-- so a trailing `$` here would require a literal dollar sign and never match.
	init = function()
		vim.filetype.add({ pattern = { [".*%.go"] = { "go", { priority = 1 } } } })
	end,
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
		{
			"<leader>.",
			function()
				Snacks.scratch()
			end,
			desc = "Toggle scratch buffer",
		},
		{
			"<leader>S",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select scratch buffer",
		},
		{
			"<leader>t",
			function()
				Snacks.terminal.toggle()
			end,
			desc = "Toggle terminal",
		},
	},
	opts = {
		-- 512KB, not the 1.5MB default: folding starts a treesitter parser everywhere
		-- else, so this alone keeps one off large files. Go is exempt; see init above.
		bigfile = { enabled = true, size = 512 * 1024 },
		dashboard = { enabled = true },
		explorer = { enabled = true },
		image = { enabled = true, doc = { max_height = 60, max_width = 200 } },
		indent = { enabled = true },
		input = { enabled = true },
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
				-- ignored stays at its default, unlike the pickers above: --no-ignore makes
				-- rg read build output and vendored trees instead of just listing their
				-- paths, which gets expensive in a large workspace. <a-i> toggles it.
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
		if vim.env.HC_TERMINAL_ID then
			herdr_app(opts)
		end
		require("snacks").setup(opts)
		-- Broken treesitter queries crash the picker:
		-- https://github.com/folke/snacks.nvim/issues/2694
		local highlight = require("snacks.picker.util.highlight")
		local get_highlights = highlight.get_highlights
		highlight.get_highlights = function(...)
			local ok, ret = pcall(get_highlights, ...)
			return ok and ret or {}
		end

		-- No inlay_hints toggle: LspAttach already binds <leader>ch.
		Snacks.toggle.diagnostics():map("<leader>ud")
		Snacks.toggle.indent():map("<leader>ug")
		Snacks.toggle.line_number():map("<leader>ul")
		Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
		Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
		Snacks.toggle.zen():map("<leader>z")
		Snacks.toggle.zoom():map("<leader>Z")
	end,
}
