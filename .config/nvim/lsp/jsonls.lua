return {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	root_markers = { ".git" },
	-- The server ships its formatter behind this flag; conform routes json to
	-- prettier anyway, so this only matters for a range format asked for by hand.
	init_options = { provideFormatter = true },
}
