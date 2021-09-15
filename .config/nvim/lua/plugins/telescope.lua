local M = {}

M.config = function()
  require("telescope").setup {
    defaults = {
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--column",
        "--glob=!**/.git/**",
        "--glob=!**/.venv/**",
        "--glob=!**/__pycache__/**",
        "--glob=!**/node_modules/**",
        "--hidden",
        "--line-number",
        "--no-heading",
        "--smart-case",
        "--with-filename"
      }
    }
  }
end

M.setup = function()
  local map = require("utils").map
  map("n", "<c-p>", "<cmd>Telescope commands<cr>")
  map("n", "<leader>ff",
    "<cmd>Telescope find_files find_command=rg,--files,--glob=!**/.git/**,--glob=!**/.venv/**,--glob=!**/__pycache__/**,--glob=!**/node_modules/**,--hidden,--no-ignore<cr>")
  map("n", "<leader>lg", "<cmd>Telescope live_grep<cr>")
  map("n", "<c-m>", "<cmd>Telescope lsp_workspace_diagnostics<cr>")
end

return M
