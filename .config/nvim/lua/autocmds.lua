local group = vim.api.nvim_create_augroup("dotfiles_autocmds", { clear = true })

local function lsp_picker(method)
	return function()
		Snacks.picker[method]()
	end
end

-- Reload buffers when files change on disk. Not on CursorHold: at a 200ms
-- updatetime that stats every loaded buffer several times a second while idle,
-- and refocusing covers the case that matters.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
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
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 180 })
	end,
})

-- nvim-treesitter's main branch installs parsers but never starts them, so
-- highlighting and the treesitter foldexpr depend on this call. Guarded because
-- start() is not idempotent -- it leaks a highlighter and its tree callbacks per
-- call -- and both lazy.nvim's FileType replay and Nvim's own ftplugins (lua,
-- markdown, help, query) would otherwise call it again.
--
-- foldmethod stays window-local: an expr foldexpr is evaluated for every line of
-- the buffer, so enabling it globally would cost a full pass on buffers that have
-- no parser to fold with.
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end

		if not vim.treesitter.highlighter.active[args.buf] then
			pcall(vim.treesitter.start, args.buf)
		end

		if vim.treesitter.highlighter.active[args.buf] then
			vim.opt_local.foldmethod = "expr"
		end
	end,
})

-- LSP keymaps and inlay hints
vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	callback = function(args)
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
		end

		-- Enabling hints on a client without the capability errors, and buf_ls has none.
		-- Which servers actually emit hints is decided in lsp/*.lua; only gopls opts in.
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
			map("n", "<leader>ch", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
			end, "Toggle inlay hints")
		end

		-- K, ]d / [d, grn, gra and gO keep Nvim's defaults.
		map("n", "gd", lsp_picker("lsp_definitions"), "Go to definition")
		map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
		map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")

		-- Shadow the gr* defaults to list results in the picker, not the quickfix list.
		map("n", "gri", lsp_picker("lsp_implementations"), "Go to implementation")
		map("n", "grr", lsp_picker("lsp_references"), "References")
		map("n", "grt", lsp_picker("lsp_type_definitions"), "Type definition")
	end,
})
