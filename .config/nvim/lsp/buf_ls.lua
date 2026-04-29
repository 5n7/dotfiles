return {
	-- stderr lands in lsp.log, where the default color format leaves ANSI escapes.
	cmd = { "buf", "lsp", "serve", "--log-format=text" },
	filetypes = { "proto" },
	root_markers = { ".git", "buf.work.yaml", "buf.yaml" },
}
