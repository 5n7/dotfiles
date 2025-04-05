local wez = require("wezterm")
local act = wez.action

return {
	-- https://wezterm.org/config/lua/general.html

	audible_bell = "Disabled",

	window_background_opacity = 0.8,
	macos_window_background_blur = 20,
	show_new_tab_button_in_tab_bar = false,
	show_close_tab_button_in_tabs = false,

	colors = {
		tab_bar = {
			inactive_tab_edge = "none",
		},
	},

	-- Hide titlebar but keep resizable border
	window_decorations = "RESIZE",

	color_scheme = "Catppuccin Mocha",
	font = wez.font("Hack Nerd Font"),
	font_size = 13,

	disable_default_key_bindings = true,
	leader = { key = "f", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = {
		{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
		{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
		{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
		{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

		{ key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "s", mods = "LEADER", action = act.PaneSelect({ alphabet = "1234567890", mode = "Activate" }) },
		{
			key = "s",
			mods = "LEADER|CTRL",
			action = act.PaneSelect({ alphabet = "1234567890", mode = "SwapWithActive" }),
		},
		{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },

		{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },

		-- mode triggers
		{
			key = "p",
			mods = "LEADER",
			action = act.ActivateKeyTable({ name = "pane_edit_mode", one_shot = false }),
		},
		{ key = "v", mods = "LEADER", action = act.ActivateCopyMode },

		{ key = "q", mods = "SUPER", action = act.QuitApplication },

		{
			key = "r",
			mods = "LEADER",
			action = wez.action.ReloadConfiguration,
		},

		{
			key = "/",
			mods = "LEADER",
			action = act.Search({ CaseInSensitiveString = "" }),
		},

		{
			key = "u",
			mods = "LEADER",
			action = act.QuickSelectArgs({
				label = "open",
				patterns = {
					"https?://\\S+",
				},
				skip_action_on_paste = true,
				action = wez.action_callback(function(window, pane)
					wez.open_with(window:get_selection_text_for_pane(pane))
				end),
			}),
		},

		{
			key = "$",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = "Rename workspace:",
				initial_value = wez.mux.get_active_workspace(),
				action = wez.action_callback(function(window, pane, line)
					if line then
						wez.mux.rename_workspace(wez.mux.get_active_workspace(), line)
					end
				end),
			}),
		},
		{
			key = ",",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = "Rename tab:",
				action = wez.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},

		{
			key = "P",
			mods = "SUPER|SHIFT",
			action = act.ActivateCommandPalette,
		},

		{ key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
		{
			key = "c",
			mods = "LEADER|CTRL",
			action = act.PromptInputLine({
				description = "Workspace name:",
				action = wez.action_callback(function(window, pane, line)
					if line then
						window:perform_action(
							act.SwitchToWorkspace({
								name = line,
							}),
							pane
						)
					end
				end),
			}),
		},
		{
			key = "w",
			mods = "LEADER|CTRL",
			action = act.ShowLauncherArgs({ flags = "WORKSPACES", title = "Select workspace" }),
		},

		{ key = "w", mods = "LEADER", action = act.ShowTabNavigator },
		{ key = "Tab", mods = "LEADER", action = act.ActivateLastTab },

		-- Switch to tabs by number
		{ key = "1", mods = "LEADER", action = act.ActivateTab(0) },
		{ key = "2", mods = "LEADER", action = act.ActivateTab(1) },
		{ key = "3", mods = "LEADER", action = act.ActivateTab(2) },
		{ key = "4", mods = "LEADER", action = act.ActivateTab(3) },
		{ key = "5", mods = "LEADER", action = act.ActivateTab(4) },
		{ key = "6", mods = "LEADER", action = act.ActivateTab(5) },
		{ key = "7", mods = "LEADER", action = act.ActivateTab(6) },
		{ key = "8", mods = "LEADER", action = act.ActivateTab(7) },
		{ key = "9", mods = "LEADER", action = act.ActivateTab(8) },
		{ key = "0", mods = "LEADER", action = act.ActivateTab(9) },

		-- Open a new wezterm window with cmd+n
		{ key = "n", mods = "SUPER", action = act.SpawnWindow },
	},
	key_tables = {
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
			{
				key = "PageUp",
				mods = "NONE",
				action = act.CopyMode("PriorMatchPage"),
			},
			{
				key = "PageDown",
				mods = "NONE",
				action = act.CopyMode("NextMatchPage"),
			},
			{ key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
			{
				key = "DownArrow",
				mods = "NONE",
				action = act.CopyMode("NextMatch"),
			},
		},
	},
}
