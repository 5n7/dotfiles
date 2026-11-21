# herdr: terminal workspace manager for AI coding agents. https://herdr.dev
# config.toml is rendered by Nix, so the in-app Settings UI cannot persist
# changes to it (herdr writes theme, toast delivery, sound, status indicators,
# agent panel sort, and onboarding back to this file). Edit here and run
# `herdr server reload-config`.
# Agent integrations (`herdr integration install <agent>`) are not declared here:
# they patch other tools' config files, such as ~/.claude/settings.json.
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  toml = pkgs.formats.toml { };

  # TokyoNight Storm, the ghostty theme. herdr's built-in tokyo-night is the
  # Night variant, whose highlight backgrounds are tuned for #1a1b26 and nearly
  # vanish against Storm's #24283b.
  storm = {
    bg_highlight = "#292e42";
    bg_visual = "#2e3c64";
    blue = "#7aa2f7";
    magenta = "#bb9af7";
  };

  # rows_by_agent replaces `rows` rather than extending it, so these restate the
  # default rows, minus `machine`, with the terminal title minus the spinner
  # glyph added as the middle row. Colour, not herdr's default bold workspace,
  # tells the tokens apart.
  agentSidebarRows = [
    [
      "state_icon"
      {
        token = "workspace";
        fg = storm.blue;
        bold = false;
      }
      "tab"
    ]
    [
      {
        token = "terminal_title_stripped";
        dim = true;
      }
    ]
    [
      {
        token = "agent";
        fg = storm.magenta;
      }
    ]
  ];

  # Only values that differ from herdr's defaults; `herdr --default-config`
  # prints the full set.
  herdrConfig = toml.generate "config.toml" {
    # Missing or true reopens first-run setup on every start.
    onboarding = false;

    keys = {
      # ctrl+f rather than the herdr default ctrl+b, matching the old tmux
      # prefix. This takes ctrl+f away from the programs inside a pane,
      # including Neovim's page-down, and from copy mode's page-forward.
      prefix = "ctrl+f";

      # Tab cycling moves onto prefix+tab, which herdr gives to pane cycling by
      # default. A configured binding beats a default one, so the pane cycle
      # drops those keys; panes stay reachable with prefix+hjkl.
      next_tab = "prefix+tab";
      previous_tab = "prefix+shift+tab";

      # prefix+n/p are herdr's tab keys; freed by the move to prefix+tab, they
      # step between workspaces instead, which herdr leaves unbound. Workspaces
      # are the outer ring, so they get the plain keys and tabs the modified one.
      next_workspace = "prefix+n";
      previous_workspace = "prefix+p";

      # Side-by-side split on prefix+\, so the key mirrors the divider it draws
      # and pairs with the stacked split already on prefix+minus.
      split_vertical = "prefix+backslash";

      # Copy mode moves off herdr's default prefix+[ to the v that split_vertical
      # just freed. Within copy mode v starts a selection, which is a different
      # mode and does not collide with the prefix binding.
      copy_mode = "prefix+v";

      command = [
        # A throwaway shell in a popup, which leaves the tiled layout alone.
        # `exec` replaces the wrapper shell, so one exit closes the popup.
        {
          key = "prefix+t";
          type = "popup";
          command = ''exec "''${SHELL:-sh}"'';
          description = "scratch terminal";
          width = "80%";
          height = "80%";
        }
        # herdr-navigator's README suggests prefix+t, which the scratch terminal
        # holds. prefix+space sits outside the tab, pane, and agent groups,
        # fitting a picker that reaches every kind of target.
        {
          key = "prefix+space";
          type = "plugin_action";
          command = "herdr-navigator.open";
          description = "navigator";
        }
        # prefix+y reads as yank and prefix+u as url, since herdr already spends
        # prefix+o on open_notification_target.
        {
          key = "prefix+y";
          type = "plugin_action";
          command = "rmarganti.herdr-pluck.pluck";
          description = "pluck visible token";
        }
        {
          key = "prefix+u";
          type = "plugin_action";
          command = "rmarganti.herdr-pluck.open-url";
          description = "open visible URL";
        }
        # The plugin already evens the layout on pane.created, pane.closed, and
        # pane.moved; this catches what those events miss, such as a layout
        # restored from before the plugin was linked. shift+e reads as "even".
        {
          key = "prefix+shift+e";
          type = "plugin_action";
          command = "herdr-even-layout.even";
          description = "even pane layout";
        }
      ];
    };

    theme = {
      # The nearest built-in to ghostty's TokyoNight Storm; see `storm` above.
      name = "tokyo-night";

      # tokyo-night paints panels opaque, which hides ghostty's
      # background-opacity behind the tab bar, menus, and dialogs. "reset" hands
      # those cells back to the terminal background. The sidebar already
      # inherits it, since sidebar_bg is unset.
      custom = {
        panel_bg = "reset";

        # Magenta rather than the theme's blue, so borders and focus stand apart
        # from the blue workspace names in the sidebar.
        accent = storm.magenta;
        active_row_bg = storm.bg_highlight;
        selection_bg = storm.bg_visual;
        surface0 = storm.bg_highlight;
      };
    };

    ui = {
      # Order the Agent panel as an attention queue rather than by space, so a
      # blocked agent surfaces without scanning the list.
      agent_panel_sort = "priority";

      # An unnamed tab is just its index, so the name prompt buys nothing. An
      # unnamed workspace is still labelled from its cwd.
      prompt_new_tab_name = false;

      # Name the agent on each split pane's top border. The label needs that
      # border, so pane_outer_borders must stay on or top-row panes lose it.
      show_agent_labels_on_pane_borders = true;

      sidebar.agents.rows_by_agent = {
        claude = agentSidebarRows;
        codex = agentSidebarRows;
        grok = agentSidebarRows;
      };

      # herdr's default space rows. herdr bolds the focused workspace and colours
      # only its branch; here none is bold and every branch is magenta.
      sidebar.spaces.rows = [
        [
          "state_icon"
          {
            token = "workspace";
            bold = false;
          }
        ]
        [
          {
            token = "branch";
            fg = storm.magenta;
          }
          "git_status"
        ]
      ];

      # Popups are off by default, which defeats the point of watching agents for
      # a blocked prompt. `terminal` hands the notification to ghostty, so it
      # needs no extra package and survives SSH; `system` would need
      # terminal-notifier.
      toast.delivery = "terminal";
    };

    # herdr is installed by Nix, so `herdr update` is disabled and the in-app new
    # version notice is noise. manifest_check stays on: it refreshes agent
    # detection rules, which is unrelated to the binary.
    update.version_check = false;

    experimental = {
      # Agent TUIs that hide the hardware cursor stop native IME candidate
      # windows from following the focused pane. The filter keeps the extra
      # cursor anchor out of unrelated panes.
      reveal_hidden_cursor_for_cjk_ime = true;
      cjk_ime_agents = [
        "claude"
        "codex"
        "grok"
      ];
      # ctrl+f survives an active IME, but the plain letter after it does not.
      # This also covers navigate, copy, resize, menu, and keybind-help modes,
      # which are all driven by bare keys.
      switch_ascii_input_source_in_prefix = true;
    };
  };

  navigatorConfig = toml.generate "navigator-config.toml" {
    picker = {
      # The binary is pinned by the flake, so the daily release check can only
      # report a version Nix will not install.
      check_updates = false;
      # The default order minus the two herdr-plus sources, disabled below, and
      # the plugin source, which an unlisted rank puts below every listed one.
      source_order = [
        "workspace"
        "agent"
        "session"
        "zoxide"
        "root"
        "server"
      ];
    };

    sources = {
      # herdr-plus is not installed, so both of its sources would always be empty.
      herdr_plus_projects = false;
      herdr_plus_quick_actions = false;
    };

    # ghq keeps checkouts at $GHQ_ROOT/<host>/<owner>/<repo>. Navigator stops
    # before checking depth 0, so depth 4 reaches repositories under ~/src.
    roots = [
      {
        path = "~/src";
        max_depth = 4;
      }
    ];
  };

  herdrCompletion =
    pkgs.runCommand "herdr-zsh-completion" { }
      "${pkgs.herdr}/bin/herdr completion zsh > $out";

  # A separate script so shellcheck runs on it at build time and it can be run
  # by hand.
  herdr-plugins-sync = pkgs.writeShellApplication {
    name = "herdr-plugins-sync";
    runtimeInputs = [
      pkgs.herdr
      pkgs.jq
    ];
    text = builtins.readFile ./herdr/plugins-sync.sh;
  };

  plugins = import ./herdr/plugins.nix {
    inherit
      inputs
      lib
      pkgs
      ;
  };

  pluginManifest = pkgs.writeText "herdr-plugins-manifest.json" (
    builtins.toJSON (
      lib.mapAttrs (_: plugin: {
        path = plugin.package;
        inherit (plugin) enabled;
      }) plugins
    )
  );
in
{
  home.packages = [ pkgs.herdr ];

  xdg.configFile."herdr/config.toml".source = herdrConfig;

  # herdr derives this directory from the plugin id (src/plugin_paths.rs). Only
  # the file is symlinked, so the directory stays writable for the jump-back and
  # pinned-entry state navigator keeps beside it.
  xdg.configFile."herdr/plugins/config/herdr-navigator/config.toml".source = navigatorConfig;

  # ZDOTDIR/completions is added to fpath by ./zsh/fpath.zsh.
  xdg.configFile."zsh/completions/_herdr".source = herdrCompletion;

  # ~/.config/herdr/plugins.json is owned by the server and written only by
  # `plugin link`/`unlink`, so it cannot be a store symlink; reconciling it on
  # every activation gets the same result without a restart. One `run` wraps the
  # whole script, so `--dry-run` names the script, not its link and unlink calls.
  home.activation.herdrPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe herdr-plugins-sync} ${lib.escapeShellArg pluginManifest}
  '';
}
