return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".git", ".luacheckrc", ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml" },
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = { checkThirdParty = false },
		},
	},
}
