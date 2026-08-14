-- Used by root_dir below; the root_markers option is only consulted when root_dir is unset.
local root_markers = { ".git", "go.mod", "go.work" }

local dep_dirs --- @type string[]?

--- GOMODCACHE and GOROOT, the read-only trees dependency sources live in.
local function readonly_dep_dirs()
	if dep_dirs then
		return dep_dirs
	end

	local gomodcache = vim.env.GOMODCACHE
	local goroot = vim.env.GOROOT
	if not gomodcache and vim.env.GOPATH then
		gomodcache = vim.fs.joinpath(vim.env.GOPATH, "pkg", "mod")
	end

	-- Ask go only for what the environment did not already answer.
	if not (gomodcache and goroot) then
		local out = vim.system({ "go", "env", "GOMODCACHE", "GOROOT" }, { text = true }):wait()
		if out.code == 0 then
			local lines = vim.split(vim.trim(out.stdout or ""), "\n")
			gomodcache = gomodcache or lines[1]
			goroot = goroot or lines[2]
		end
	end

	local dirs = {}
	for _, dir in ipairs({ gomodcache, goroot }) do
		if dir and dir ~= "" then
			table.insert(dirs, vim.fs.normalize(dir))
		end
	end

	-- Cache only a non-empty answer, so a missing go on PATH is not permanent.
	if #dirs > 0 then
		dep_dirs = dirs
	end

	return dirs
end

--- The gopls owning the tree we are working in, preferring the one rooted at cwd.
local function project_client()
	local clients = vim.lsp.get_clients({ name = "gopls" })
	local cwd = vim.fs.normalize(vim.uv.cwd() or "")

	for _, client in ipairs(clients) do
		if client.root_dir and vim.startswith(cwd, vim.fs.normalize(client.root_dir)) then
			return client
		end
	end

	return clients[1]
end

return {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gotmpl", "gowork" },
	root_dir = function(bufnr, on_dir)
		local fname = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))

		for _, dir in ipairs(readonly_dep_dirs()) do
			if vim.startswith(fname, dir .. "/") then
				-- Module cache dirs have their own go.mod, so marker resolution would root a
				-- second gopls there on every jump into a dependency. That one sees only the
				-- module it landed in, so references and implementations come back incomplete.
				-- Passing the project client's root_dir is what makes nvim reuse it instead.
				local client = project_client()
				if client then
					on_dir(client.root_dir)
				end
				-- Nothing to reuse: stay detached rather than index the module cache.
				return
			end
		end

		on_dir(vim.fs.root(bufnr, root_markers))
	end,
	settings = {
		gopls = {
			-- Replaces the default -**/node_modules rather than merging with it. .wt holds
			-- herdr worktrees, each a full copy of the tree they sit in.
			directoryFilters = { "-**/.wt" },
			-- Limits symbol search to workspace packages; the default searches dependencies too.
			symbolScope = "workspace",
		},
	},
}
