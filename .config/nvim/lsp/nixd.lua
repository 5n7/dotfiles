--- Flake ref for `builtins.getFlake`, or nil when root holds no flake.
local function flake_ref(root)
	if not root or not vim.uv.fs_stat(vim.fs.joinpath(root, "flake.nix")) then
		return nil
	end

	-- The `path:` fetcher copies the directory wholesale and aborts on the socket
	-- git's fsmonitor daemon leaves behind ("file '.git/fsmonitor--daemon.ipc' has
	-- an unsupported type"). git+file:// reads the tracked files through git, and
	-- still sees uncommitted edits.
	if vim.uv.fs_stat(vim.fs.joinpath(root, ".git")) then
		return "git+file://" .. root
	end

	return "path:" .. root
end

--- What nixd should evaluate to answer completion in the flake at ref.
---
--- Everything is derived from the LSP root instead of hardcoding this checkout,
--- so the same config serves any flake; the `or` fallbacks make a flake without
--- system configurations yield an empty option set rather than an eval error.
local function flake_settings(ref)
	local prelude = ([[
		let
		  flake = builtins.getFlake "%s";
		  configs = builtins.attrValues (flake.darwinConfigurations or flake.nixosConfigurations or { });
		in
	]]):format(ref)

	return {
		-- Package completion off the flake's own nixpkgs, so what is offered is what
		-- the flake would build. Falls back to nixd's default, `import <nixpkgs> { }`.
		nixpkgs = {
			expr = ([[
				let flake = builtins.getFlake "%s"; in
				if flake ? inputs.nixpkgs then import flake.inputs.nixpkgs { } else import <nixpkgs> { }
			]]):format(ref),
		},
		options = {
			-- Which host is picked does not matter: the hosts here differ only in the
			-- arguments handed to the same modules, not in the options they declare.
			["nix-darwin"] = {
				expr = prelude .. "if configs == [ ] then { } else (builtins.head configs).options",
			},
			-- home-manager is a submodule of the system config, so its options only
			-- exist below home-manager.users; getSubOptions lifts them out of the
			-- attrsOf and leaves the per-user options addressable as themselves.
			["home-manager"] = {
				expr = prelude .. [[
					if configs == [ ] then
					  { }
					else
					  let options = (builtins.head configs).options; in
					  if options ? home-manager then options.home-manager.users.type.getSubOptions [ ] else { }
				]],
			},
		},
	}
end

return {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { ".git", "flake.nix" },
	-- The flake ref is only known once the root is resolved, which is after the
	-- config table is read. Assigning here covers both ways nixd asks for settings:
	-- the notification below, and the workspace/configuration pulls nvim answers
	-- from client.settings.
	on_init = function(client)
		local ref = flake_ref(client.root_dir)
		if not ref then
			return
		end

		client.settings = vim.tbl_deep_extend("force", client.settings or {}, { nixd = flake_settings(ref) })
		client:notify("workspace/didChangeConfiguration", { settings = client.settings })
	end,
	settings = {
		nixd = {
			-- conform has no nix formatter, and format_on_save falls back to the LSP,
			-- so this is what formats nix buffers. nixfmt is also what `nix fmt` runs
			-- through treefmt.nix, so both paths produce the same file.
			formatting = { command = { "nixfmt" } },
		},
	},
}
