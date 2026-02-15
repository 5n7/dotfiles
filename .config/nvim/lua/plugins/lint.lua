return {
	"mfussenegger/nvim-lint",
	event = { "BufNewFile", "BufReadPost", "BufWritePost" },
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

		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
