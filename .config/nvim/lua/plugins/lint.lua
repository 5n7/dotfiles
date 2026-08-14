return {
	"mfussenegger/nvim-lint",
	-- Read triggers are deliberately absent. nvim-lint invokes golangci-lint on the
	-- buffer's parent directory, so every linted buffer type-checks a whole package and
	-- its dependencies. Linting on read means each jump into a new file starts another
	-- one of those, and in a large workspace they pile up in parallel.
	event = { "BufWritePost" },
	config = function()
		local lint = require("lint")

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
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
