local map = vim.keymap.set

-- Insert mode
map("i", "jj", "<esc>", { desc = "Exit insert mode" })

-- Visual line movement
map({ "n", "v" }, "j", "gj", { desc = "Move down (display line)" })
map({ "n", "v" }, "k", "gk", { desc = "Move up (display line)" })
map({ "n", "v" }, "gj", "j", { desc = "Move down (real line)" })
map({ "n", "v" }, "gk", "k", { desc = "Move up (real line)" })

-- Window split
map("n", "sh", "<c-w>s", { desc = "Split horizontal" })
map("n", "sv", "<c-w>v", { desc = "Split vertical" })

-- Window navigation
map("n", "<c-h>", "<c-w>h", { desc = "Go to left window" })
map("n", "<c-j>", "<c-w>j", { desc = "Go to lower window" })
map("n", "<c-k>", "<c-w>k", { desc = "Go to upper window" })
map("n", "<c-l>", "<c-w>l", { desc = "Go to right window" })

-- Window resize
map("n", "<m-H>", "<cmd>vertical resize -10<cr>", { desc = "Decrease width" })
map("n", "<m-J>", "<cmd>resize +5<cr>", { desc = "Increase height" })
map("n", "<m-K>", "<cmd>resize -5<cr>", { desc = "Decrease height" })
map("n", "<m-L>", "<cmd>vertical resize +10<cr>", { desc = "Increase width" })

-- Black hole delete
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yank" })
map({ "n", "v" }, "<leader>x", '"_x', { desc = "Remove char without yank" })

-- Buffer navigation
map("n", "<m-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
map("n", "<m-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })

-- Save / Quit
map("n", "<leader>q", "<cmd>q!<cr>", { desc = "Force quit" })
map("n", "<leader>w", "<cmd>wa<cr>", { desc = "Save all" })
map("n", "<leader>W", "<cmd>noa wa<cr>", { desc = "Save all (no autocmd)" })

-- Misc
map("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
