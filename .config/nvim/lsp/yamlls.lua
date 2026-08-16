return {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
	root_markers = { ".git" },
	settings = {
		yaml = {
			-- Pulls the SchemaStore catalog and matches schemas by filename, which is
			-- what validates workflows, compose files and the like without listing a
			-- schema per project. The server fetches and caches it itself.
			schemaStore = { enable = true, url = "https://www.schemastore.org/api/json/catalog.json" },
			-- Defaults to true, which flags every file whose keys are not sorted.
			keyOrdering = false,
		},
		redhat = { telemetry = { enabled = false } },
	},
}
