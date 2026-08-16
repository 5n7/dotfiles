return {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	root_markers = { ".git" },
	-- The server ships its formatter behind this flag; conform routes json to
	-- prettier anyway, so this only matters for a range format asked for by hand.
	init_options = { provideFormatter = true },
	settings = {
		json = {
			validate = { enable = true },
			-- Unlike yaml-language-server this one cannot read the SchemaStore
			-- catalog, so associations are listed by hand. Covering the whole
			-- catalog needs a plugin (b0o/SchemaStore.nvim) that ships it as lua.
			schemas = {
				{ fileMatch = { "package.json" }, url = "https://json.schemastore.org/package.json" },
				{
					fileMatch = { "tsconfig.json", "tsconfig.*.json" },
					url = "https://json.schemastore.org/tsconfig.json",
				},
				{
					fileMatch = { "jsconfig.json", "jsconfig.*.json" },
					url = "https://json.schemastore.org/jsconfig.json",
				},
				{
					fileMatch = { ".prettierrc", ".prettierrc.json" },
					url = "https://json.schemastore.org/prettierrc.json",
				},
				{ fileMatch = { ".eslintrc", ".eslintrc.json" }, url = "https://json.schemastore.org/eslintrc.json" },
				{
					fileMatch = { ".claude/settings.json", ".claude/settings.local.json" },
					url = "https://json.schemastore.org/claude-code-settings.json",
				},
			},
		},
	},
}
