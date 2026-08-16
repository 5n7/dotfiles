return {
	cmd = { "bash-language-server", "start" },
	-- zsh is deliberately absent: the server parses everything as bash, so the zsh
	-- files under modules/home/zsh would come back full of syntax errors.
	filetypes = { "bash", "sh" },
	root_markers = { ".git" },
	settings = {
		bashIde = {
			-- Almost every diagnostic bashls reports comes from shellcheck, which it
			-- shells out to; the wrapper's PATH supplies it (see modules/home/editor.nix).
			shellcheckPath = "shellcheck",
		},
	},
}
