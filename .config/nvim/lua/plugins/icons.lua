return {
	"echasnovski/mini.icons",
	lazy = true,
	opts = {},
	init = function()
		-- Keeps plugins that still require("nvim-web-devicons") on the same icon set.
		package.preload["nvim-web-devicons"] = function()
			require("mini.icons").mock_nvim_web_devicons()
			return package.loaded["nvim-web-devicons"]
		end
	end,
}
