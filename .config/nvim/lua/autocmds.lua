local group = vim.api.nvim_create_augroup("dotfiles_autocmds", { clear = true })

local function lsp_picker(method, fallback)
	return function()
		local ok, snacks = pcall(require, "snacks")
		if ok and snacks.picker and snacks.picker[method] then
			snacks.picker[method]()
			return
		end

		fallback()
	end
end

local ts_disabled_by_ft = {}
local ts_max_filesize = 512 * 1024

local function is_large_file(buf)
	local path = vim.api.nvim_buf_get_name(buf)
	if path == "" then
		return false
	end

	local stat = vim.uv.fs_stat(path)
	return stat and stat.size and stat.size > ts_max_filesize or false
end

local function set_treesitter_folds(buf)
	if vim.bo[buf].buftype ~= "" then
		return
	end

	local ft = vim.bo[buf].filetype
	if ft == "" or ft == "bigfile" or ts_disabled_by_ft[ft] or is_large_file(buf) then
		return
	end

	local lang = vim.treesitter.language.get_lang(ft) or ft
	local ok = pcall(vim.treesitter.start, buf, lang)
	if not ok then
		ts_disabled_by_ft[ft] = true
		return
	end

	local wins = vim.fn.win_findbuf(buf)
	if #wins == 0 and vim.api.nvim_get_current_buf() == buf then
		wins = { vim.api.nvim_get_current_win() }
	end

	for _, win in ipairs(wins) do
		vim.api.nvim_win_call(win, function()
			vim.opt_local.foldmethod = "expr"
			vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		end)
	end
end

-- Reload buffers when files change on disk
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	group = group,
	command = "checktime",
})

-- Disable auto-comment on new lines
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "o", "r" })
	end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 180 })
	end,
})

-- Treesitter-based folding for parser-backed filetypes
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost", "FileType" }, {
	group = group,
	callback = function(args)
		set_treesitter_folds(args.buf)
	end,
})

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	callback = function(args)
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
		end

		map("n", "gd", lsp_picker("lsp_definitions", vim.lsp.buf.definition), "Go to definition")
		map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
		map("n", "gi", lsp_picker("lsp_implementations", vim.lsp.buf.implementation), "Go to implementation")
		map("n", "gr", lsp_picker("lsp_references", vim.lsp.buf.references), "References")
		map("n", "gy", lsp_picker("lsp_type_definitions", vim.lsp.buf.type_definition), "Type definition")
		map("n", "K", vim.lsp.buf.hover, "Hover")
		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
		map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")
		map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
		map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
		map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
	end,
})
