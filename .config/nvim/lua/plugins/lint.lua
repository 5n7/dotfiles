local function eslint_command(bufnr)
	for dir in vim.fs.parents(vim.api.nvim_buf_get_name(bufnr)) do
		local command = vim.fs.joinpath(dir, "node_modules", ".bin", "eslint")
		if vim.fn.executable(command) == 1 then
			return command
		end
	end
end

return {
	"mfussenegger/nvim-lint",
	-- Read triggers are deliberately absent. nvim-lint invokes golangci-lint on the
	-- buffer's parent directory, so every linted buffer type-checks a whole package and
	-- its dependencies. Linting on read means each jump into a new file starts another
	-- one of those, and in a large workspace they pile up in parallel.
	event = { "BufWritePost" },
	config = function()
		local lint = require("lint")

		-- ESLint is project-local, including hoisted workspace installations.
		lint.linters_by_ft = {
			go = { "golangcilint" },
			javascript = { "eslint" },
			javascriptreact = { "eslint" },
			proto = { "buf_lint" },
			typescript = { "eslint" },
			typescriptreact = { "eslint" },
		}

		vim.api.nvim_create_autocmd("BufWritePost", {
			group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
			callback = function(args)
				local linters = lint.linters_by_ft[vim.bo[args.buf].filetype] or {}
				if not vim.list_contains(linters, "eslint") then
					lint.try_lint()
					return
				end

				local command = eslint_command(args.buf)
				if command then
					lint.try_lint("eslint", {
						cwd = vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf)),
						wrap_linter = function(linter)
							linter.cmd = command
							return linter
						end,
					})
				end
			end,
		})
	end,
}
