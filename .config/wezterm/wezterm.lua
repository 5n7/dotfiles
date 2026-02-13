local wez = require("wezterm")
local act = wez.action
local config = wez.config_builder()

-- Performance
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.max_fps = 120
config.animation_fps = 60

-- Appearance
config.color_scheme = "Tokyo Night Storm"
config.font = wez.font("Hack Nerd Font")
config.font_size = 13
config.line_height = 1.1
config.audible_bell = "Disabled"
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 600

-- Window
config.window_background_opacity = 0.85
config.macos_window_background_blur = 30
config.window_decorations = "RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 0 }
config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = "NeverPrompt"
config.native_macos_fullscreen_mode = true

-- Pane
config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.7,
}

-- Tab bar
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.tab_max_width = 32
config.colors = {
	tab_bar = {
		background = "#1a1b26",
		inactive_tab_edge = "none",
		active_tab = {
			bg_color = "#7aa2f7",
			fg_color = "#1a1b26",
		},
		inactive_tab = {
			bg_color = "#292e42",
			fg_color = "#565f89",
		},
		inactive_tab_hover = {
			bg_color = "#3b4261",
			fg_color = "#c0caf5",
		},
	},
}

-- Scrollback
config.scrollback_lines = 10000

-- Quick select
config.quick_select_remove_styling = true

-- Keys
config.disable_default_key_bindings = true
config.leader = { key = "f", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- macOS standard
	{ key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
	{ key = "q", mods = "SUPER", action = act.QuitApplication },
	{ key = "n", mods = "SUPER", action = act.SpawnWindow },
	{ key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "SUPER", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "=", mods = "SUPER", action = act.IncreaseFontSize },
	{ key = "-", mods = "SUPER", action = act.DecreaseFontSize },
	{ key = "0", mods = "SUPER", action = act.ResetFontSize },
	{ key = "Enter", mods = "SUPER", action = act.ToggleFullScreen },
	{ key = "k", mods = "SUPER", action = act.ClearScrollback("ScrollbackAndViewport") },
	{ key = "P", mods = "SUPER|SHIFT", action = act.ActivateCommandPalette },

	-- Pane navigation
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- Pane management
	{ key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "s", mods = "LEADER", action = act.PaneSelect({ alphabet = "1234567890", mode = "Activate" }) },
	{ key = "s", mods = "LEADER|CTRL", action = act.PaneSelect({ alphabet = "1234567890", mode = "SwapWithActive" }) },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

	-- Tab
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "LEADER", action = act.ShowTabNavigator },
	{ key = "Tab", mods = "LEADER", action = act.ActivateLastTab },
	{ key = "1", mods = "LEADER", action = act.ActivateTab(0) },
	{ key = "2", mods = "LEADER", action = act.ActivateTab(1) },
	{ key = "3", mods = "LEADER", action = act.ActivateTab(2) },
	{ key = "4", mods = "LEADER", action = act.ActivateTab(3) },
	{ key = "5", mods = "LEADER", action = act.ActivateTab(4) },
	{ key = "6", mods = "LEADER", action = act.ActivateTab(5) },
	{ key = "7", mods = "LEADER", action = act.ActivateTab(6) },
	{ key = "8", mods = "LEADER", action = act.ActivateTab(7) },
	{ key = "9", mods = "LEADER", action = act.ActivateTab(8) },

	-- Tab rename
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Rename tab:",
			action = wez.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Workspace
	{
		key = "c",
		mods = "LEADER|CTRL",
		action = act.PromptInputLine({
			description = "Workspace name:",
			action = wez.action_callback(function(window, pane, line)
				if line then
					window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		}),
	},
	{
		key = "w",
		mods = "LEADER|CTRL",
		action = act.ShowLauncherArgs({ flags = "WORKSPACES", title = "Select workspace" }),
	},
	{
		key = "$",
		mods = "LEADER",
		action = wez.action_callback(function(window, pane)
			local current = window:active_workspace()
			window:perform_action(
				act.PromptInputLine({
					description = "Rename workspace:",
					initial_value = current,
					action = wez.action_callback(function(_, _, line)
						if line then
							wez.mux.rename_workspace(current, line)
						end
					end),
				}),
				pane
			)
		end),
	},

	-- Project workspace switcher
	{
		key = "S",
		mods = "LEADER",
		action = wez.action_callback(function(window, pane)
			local home = os.getenv("HOME")
			local base = home .. "/src/github.com"
			local projects = {}
			for _, path in ipairs(wez.glob(base .. "/*/*")) do
				local org, name = path:match("([^/]+)/([^/]+)$")
				if org and name then
					table.insert(projects, { id = path, label = org .. "/" .. name })
				end
			end
			window:perform_action(
				act.InputSelector({
					title = "Switch Workspace",
					choices = projects,
					action = wez.action_callback(function(inner_window, inner_pane, id, label)
						if id and label then
							inner_window:perform_action(
								act.SwitchToWorkspace({ name = label, spawn = { cwd = id } }),
								inner_pane
							)
						end
					end),
				}),
				pane
			)
		end),
	},

	-- Quick launch
	{
		key = "g",
		mods = "LEADER",
		action = wez.action_callback(function(window, pane)
			local cwd = pane:get_current_working_dir().file_path
			window:perform_action(act.SpawnCommandInNewTab({ args = { "/bin/zsh", "-lc", "gitui" }, cwd = cwd }), pane)
		end),
	},
	{
		key = "f",
		mods = "LEADER",
		action = wez.action_callback(function(window, pane)
			local cwd = pane:get_current_working_dir().file_path
			window:perform_action(act.SpawnCommandInNewTab({ args = { "/bin/zsh", "-lc", "yazi" }, cwd = cwd }), pane)
		end),
	},

	-- URL open
	{
		key = "u",
		mods = "LEADER",
		action = act.QuickSelectArgs({
			label = "open",
			patterns = { "https?://\\S+" },
			skip_action_on_paste = true,
			action = wez.action_callback(function(window, pane)
				wez.open_with(window:get_selection_text_for_pane(pane))
			end),
		}),
	},

	-- Modes
	{ key = "p", mods = "LEADER", action = act.ActivateKeyTable({ name = "pane_edit_mode", one_shot = false }) },
	{ key = "v", mods = "LEADER", action = act.ActivateCopyMode },

	-- Misc
	{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },
	{ key = "/", mods = "LEADER", action = act.Search({ CaseInSensitiveString = "" }) },
}

config.key_tables = {
	pane_edit_mode = {
		{ key = "h", action = act.ActivatePaneDirection("Left") },
		{ key = "j", action = act.ActivatePaneDirection("Down") },
		{ key = "k", action = act.ActivatePaneDirection("Up") },
		{ key = "l", action = act.ActivatePaneDirection("Right") },

		{ key = "H", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "J", action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "K", action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "L", action = act.AdjustPaneSize({ "Right", 5 }) },

		{ key = "\\", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "-", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "s", action = act.PaneSelect({ alphabet = "1234567890", mode = "Activate" }) },
		{ key = "S", action = act.PaneSelect({ alphabet = "1234567890", mode = "SwapWithActive" }) },
		{ key = "x", action = act.CloseCurrentPane({ confirm = false }) },

		{ key = "q", action = act.PopKeyTable },
		{ key = "Escape", action = act.PopKeyTable },
	},
	search_mode = {
		{ key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
		{ key = "PageUp", mods = "NONE", action = act.CopyMode("PriorMatchPage") },
		{ key = "PageDown", mods = "NONE", action = act.CopyMode("NextMatchPage") },
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
	},
}

-- Right status: LEADER indicator + workspace list + time
wez.on("update-status", function(window, pane)
	local active = window:active_workspace()
	local workspaces = wez.mux.get_workspace_names()
	local date = wez.strftime("%m/%d %H:%M")

	local elements = {}

	-- LEADER indicator
	if window:leader_is_active() then
		table.insert(elements, { Foreground = { Color = "#7aa2f7" } })
		table.insert(elements, { Attribute = { Intensity = "Bold" } })
		table.insert(elements, { Text = " LEADER " })
		table.insert(elements, "ResetAttributes")
	end

	-- Workspace list: highlight active, dim others
	for i, name in ipairs(workspaces) do
		if name == active then
			table.insert(elements, { Foreground = { Color = "#7aa2f7" } })
			table.insert(elements, { Attribute = { Intensity = "Bold" } })
			table.insert(elements, { Text = " " .. name .. " " })
			table.insert(elements, "ResetAttributes")
		else
			table.insert(elements, { Foreground = { Color = "#565f89" } })
			table.insert(elements, { Text = " " .. name .. " " })
		end
		if i < #workspaces then
			table.insert(elements, { Foreground = { Color = "#292e42" } })
			table.insert(elements, { Text = "│" })
		end
	end

	-- Time
	table.insert(elements, { Foreground = { Color = "#292e42" } })
	table.insert(elements, { Text = "  │ " })
	table.insert(elements, { Foreground = { Color = "#565f89" } })
	table.insert(elements, { Text = date .. " " })

	window:set_right_status(wez.format(elements))
end)

-- Tab title format
wez.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab.tab_title
	if #title == 0 then
		title = tab.active_pane.title
	end
	if #title > max_width - 6 then
		title = wez.truncate_right(title, max_width - 7) .. "…"
	end
	return " " .. (tab.tab_index + 1) .. ": " .. title .. " "
end)

return config
