-- A local, not the root_markers field: nvim ignores that field when root_dir is set.
local root_markers = { ".git", "go.mod", "go.work" }

local dep_dirs --- @type string[]?

local function readonly_dep_dirs()
	if dep_dirs then
		return dep_dirs
	end

	local gomodcache = vim.env.GOMODCACHE
	local goroot = vim.env.GOROOT
	if not gomodcache and vim.env.GOPATH then
		gomodcache = vim.fs.joinpath(vim.env.GOPATH, "pkg", "mod")
	end

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
	-- One server per nvim, not a shared -remote=auto daemon. fileWatcher below is
	-- kqueue-backed on macOS, so each watched path holds a file descriptor, around
	-- 5.6k for one view of merpay-payment-service. A daemon outlives its editors, and
	-- an nvim killed uncleanly leaves its session's watches behind. Sixteen stale sets
	-- in, the daemon hit kern.maxfilesperproc (122880) and every new view failed with
	-- "too many open files", shown in the editor as "no views". A server per editor
	-- gives its descriptors back when nvim exits.
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gotmpl", "gowork" },
	root_dir = function(bufnr, on_dir)
		local fname = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))

		for _, dir in ipairs(readonly_dep_dirs()) do
			if vim.startswith(fname, dir .. "/") then
				-- Module cache dirs have their own go.mod, so marker resolution would root a
				-- second gopls on every jump into a dependency, and that one sees only its own
				-- module, so references and implementations come back incomplete. Passing the
				-- project client's root_dir makes nvim reuse it instead.
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
	capabilities = {
		-- Declining dynamic registration stops gopls from installing watchers in nvim,
		-- which matches every filesystem event against globs in Lua; a branch switch or
		-- a build then stalls the UI. fileWatcher below moves the job into gopls.
		workspace = { didChangeWatchedFiles = { dynamicRegistration = false } },
	},
	settings = {
		gopls = {
			-- The default, "Edit", re-diagnoses workspace packages as you type.
			diagnosticsTrigger = "Save",
			-- Replaces the default -**/node_modules rather than merging with it, so that is
			-- listed again. .wt holds herdr worktrees, each a full copy of the tree they sit in.
			directoryFilters = { "-**/.wt", "-**/node_modules" },
			-- Server-side watching, in place of the client watchers declined above.
			fileWatcher = "fsnotify",
			-- Limits symbol search to workspace packages; the default searches dependencies too.
			symbolScope = "workspace",
		},
	},
}
