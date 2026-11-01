return {
	cmd = { "bash-language-server", "start" },
	-- zsh is deliberately absent: the server parses everything as bash, so the zsh
	-- files under modules/home/zsh would come back full of syntax errors.
	filetypes = { "bash", "sh" },
	root_markers = { ".git" },
	settings = {
		bashIde = {
			-- Empty turns linting off. bashls would otherwise run whatever shellcheck
			-- PATH resolves.
			shellcheckPath = "",
		},
	},
}
