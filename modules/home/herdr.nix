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
  # Only the values that differ from the binary's built-in defaults; herdr fills
  # in the rest at load time. Print the full set with `herdr --default-config`.
  herdrConfig = (pkgs.formats.toml { }).generate "config.toml" {
    # Missing or true reopens first-run setup on every start.
    onboarding = false;

    keys = {
      # ctrl+f rather than the herdr default ctrl+b, matching the old tmux
      # prefix. This takes ctrl+f away from the programs inside a pane,
      # including Neovim's page-down, and from copy mode's page-forward.
      prefix = "ctrl+f";

      # Tab cycling moves onto prefix+tab, which herdr gives to pane cycling by
      # default. A configured binding beats a default one, so the pane cycle
      # drops those keys; panes stay reachable with prefix+hjkl. Tab cycling
      # wraps around.
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

      command = [
        # A throwaway shell that leaves the tiled layout alone: no extra split,
        # no extra tab. `exec` replaces the wrapper shell so exiting once closes
        # the popup. Popups are a singleton, and opening one while Settings or
        # Copy mode is active returns ui_busy.
        {
          key = "prefix+t";
          type = "popup";
          command = ''exec "''${SHELL:-sh}"'';
          description = "scratch terminal";
          width = "80%";
          height = "80%";
        }
        # herdr-navigator's own README suggests prefix+t, which the scratch
        # terminal already holds. prefix+space stays free of the tab, pane, and
        # agent groups and is the one chord that reaches every kind of target.
        {
          key = "prefix+space";
          type = "plugin_action";
          command = "herdr-navigator.open";
          description = "navigator";
        }
        # Both pluck actions hint the tokens visible in the focused pane; the
        # general one copies whatever is picked, the narrow one takes URLs only
        # and hands them to the browser. prefix+y reads as yank, and prefix+u as
        # url, because herdr already spends prefix+o on open_notification_target.
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
      ];
    };

    theme = {
      # Matches ghostty's "TokyoNight Storm".
      name = "tokyo-night";

      # tokyo-night paints panels with an opaque colour, which would sit on top
      # of ghostty's background-opacity and leave the tab bar, menus, and
      # dialogs solid. "reset" hands those cells back to the terminal
      # background so the window transparency shows through. The sidebar
      # already inherits it, since sidebar_bg is unset.
      custom.panel_bg = "reset";
    };

    ui = {
      # Order the Agent panel as an attention queue rather than by space, so a
      # blocked agent surfaces without scanning the list.
      agent_panel_sort = "priority";

      # An unnamed tab is just its index, so the name prompt buys nothing. An
      # unnamed workspace is still labelled from its cwd.
      prompt_new_tab_name = false;

      # Popups are off by default, which defeats the point of watching agents for
      # a blocked prompt. `terminal` hands the notification to ghostty, so it
      # needs no extra package and survives SSH; `system` would need
      # terminal-notifier.
      toast.delivery = "terminal";

      # Claude Code panes get a third row showing what the agent is doing, taken
      # from its terminal title minus the spinner glyph. rows_by_agent replaces
      # `rows` rather than extending it, so the default two rows are repeated
      # here. Other agents keep the two-row default and stay shorter.
      sidebar.agents.rows_by_agent.claude = [
        [
          "state_icon"
          "workspace"
          "tab"
        ]
        [ "terminal_title_stripped" ]
        [ "agent" ]
      ];
    };

    # herdr is installed by Nix, so `herdr update` is disabled and the in-app new
    # version notice is noise. manifest_check stays on: it refreshes agent
    # detection rules, which is unrelated to the binary.
    update.version_check = false;

    experimental = {
      # Agent TUIs that hide the hardware cursor stop native IME candidate
      # windows from following the focused pane. The filter keeps the extra
      # cursor anchor out of unrelated panes.
      cjk_ime_agents = [
        "claude"
        "codex"
        "cursor"
        "grok"
      ];
      reveal_hidden_cursor_for_cjk_ime = true;
      # ctrl+f survives an active IME, but the plain letter after it does not.
      # This also covers navigate, copy, resize, menu, and keybind-help modes,
      # which are all driven by bare keys.
      switch_ascii_input_source_in_prefix = true;
    };
  };

  # herdr-pluck is left on its defaults, so only navigator has a plugin config.
  navigatorConfig = (pkgs.formats.toml { }).generate "navigator-config.toml" {
    picker = {
      # The binary is pinned by the flake, so the daily release check can only
      # report a version Nix will not install.
      check_updates = false;
      # Drop the two herdr-plus sources from the ranking; they are disabled below.
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

    # ghq keeps every checkout at $GHQ_ROOT/<host>/<owner>/<repo>, so depth 3 is
    # exactly one repository and no deeper. Replaces the ~/workspace and
    # ~/projects defaults, which do not exist here.
    roots = [
      {
        path = "~/src";
        max_depth = 3;
      }
    ];
  };

  herdrCompletion =
    pkgs.runCommand "herdr-zsh-completion" { }
      "${pkgs.herdr}/bin/herdr completion zsh > $out";

  # Plugins are built here instead of by `herdr plugin install`, which clones into
  # ~/.config/herdr/plugins/github and runs the manifest's [[build]] step in place.
  # `herdr plugin link` registers an existing directory and never builds, so a
  # read-only store path is a valid plugin root.
  #
  # Building under Nix also sidesteps the environment those [[build]] steps get.
  # herdr passes its own PATH straight through (src/plugin_command.rs), and the
  # server inherits ghostty's, which launchd sets to /usr/bin:/bin:/usr/sbin:/sbin
  # plus /usr/local/bin. No cargo, no bun, no Homebrew. Only plugins that build
  # with nothing, or that download a prebuilt binary, install the imperative way
  # on this machine.
  #
  # These plugins are Rust, but they are not compiled here: upstream publishes a
  # code-signed aarch64-darwin binary per release, which is exactly what their own
  # build steps download. Taking the same binary keeps a version bump to a hash
  # change instead of a cargo build.
  #
  # The flake input still supplies the manifest and any scripts the manifest runs;
  # only the executable comes from the release. Manifest commands are written
  # relative to the plugin root, but the path they use differs per plugin
  # (./target/release/<pname> for navigator, ./bin/<pname> for pluck), so
  # binaryPath names where the binary has to land.
  mkPlugin =
    {
      pname,
      version,
      src,
      binary,
      binaryPath,
    }:
    pkgs.runCommand "${pname}-${version}" { } ''
      cp -R ${src} $out
      chmod -R u+w $out
      install -Dm555 ${binary} $out/${binaryPath}
    '';

  # Attribute names are the plugin ids from each herdr-plugin.toml; the reconcile
  # script below matches on them.
  plugins = {
    herdr-navigator = mkPlugin {
      pname = "herdr-navigator";
      version = "0.3.5";
      src = inputs.herdr-navigator;
      binaryPath = "target/release/herdr-navigator";
      # Released as a tarball rather than a bare binary, so unwrap it first.
      binary = pkgs.runCommand "herdr-navigator-binary" { } ''
        tar -xzOf ${
          pkgs.fetchurl {
            url = "https://github.com/thanhdat77/herdr-navigator/releases/download/v0.3.5/herdr-navigator-macos-aarch64.tar.gz";
            hash = "sha256-0LQE2/tp9M9RhVIadLnkOchIs6tnxueskwLog7fwzBM=";
          }
        } herdr-navigator/herdr-navigator > $out
      '';
    };

    # The manifest's own [[build]] step (./scripts/install-binary.sh) only
    # downloads this release tarball, so it is skipped and the binary installed
    # here instead.
    "rmarganti.herdr-pluck" = mkPlugin {
      pname = "herdr-pluck";
      version = "0.3.1";
      src = inputs.herdr-pluck;
      binaryPath = "bin/herdr-pluck";
      # Tarball again, with the executable at the archive root this time.
      binary = pkgs.runCommand "herdr-pluck-binary" { } ''
        tar -xzOf ${
          pkgs.fetchurl {
            url = "https://github.com/rmarganti/herdr-pluck/releases/download/v0.3.1/herdr-pluck-v0.3.1-aarch64-apple-darwin.tar.gz";
            hash = "sha256-TNg86ZPjYF+ddarrK3oV9QPoDvTI+AQW55vqdyzmnH4=";
          }
        } herdr-pluck > $out
      '';
    };
  };

in
{
  home.packages = [ pkgs.herdr ];

  xdg.configFile."herdr/config.toml".source = herdrConfig;

  # herdr derives this directory from the plugin id (src/plugin_paths.rs). Only
  # config.toml is symlinked: the plugin keeps its jump-back and pinned-entry
  # state as sibling files and needs the directory itself writable.
  xdg.configFile."herdr/plugins/config/herdr-navigator/config.toml".source = navigatorConfig;

  # ZDOTDIR/completions is added to fpath by ./zsh/fpath.zsh.
  xdg.configFile."zsh/completions/_herdr".source = herdrCompletion;

  # ~/.config/herdr/plugins.json is written only by `plugin link`/`unlink`, so it
  # cannot be a store symlink. Reconciling it against `plugins` on every
  # activation gets the same result: anything not declared above is unlinked, and
  # every declared plugin is re-linked at its current store path. Linking goes
  # through the running server, so the change applies without a restart.
  home.activation.herdrPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    herdr=${lib.getExe pkgs.herdr}
    declared="${lib.concatStringsSep " " (lib.attrNames plugins)}"

    for id in $(
      "$herdr" plugin list --json | ${lib.getExe pkgs.jq} -r '.result.plugins[].plugin_id'
    ); do
      case " $declared " in
        *" $id "*) ;;
        *) run "$herdr" plugin unlink "$id" ;;
      esac
    done

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (_: package: ''run "$herdr" plugin link ${package} --enabled'') plugins
    )}
  '';
}
