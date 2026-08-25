# AeroSpace: i3-like tiling window manager for macOS. https://nikitabobko.github.io/AeroSpace
# The config is rendered by Nix into a store path and passed to the launchd agent
# with --config-path, so ~/.aerospace.toml is never read. Edit here and rebuild.
# This replaces Rectangle, which only snapped windows to halves and had no
# concept of workspaces.
{
  lib,
  host,
  ...
}:
let
  # Every workspace is reached with alt-<its own name, lowercased> and receives
  # the focused window with alt-shift-<same>, so the list below is the single
  # source of truth for both the bindings and persistent-workspaces. Lettered
  # ones are the permanent home of one app; U/O/P are scratch space, and so is I
  # outside the work profile.
  # Linear would want L, but alt-l is `focus right`, so it took X instead.
  workspaces = [
    "A" # Claude
    "B" # Google Chrome, Dia (personal)
    "N" # Notion
    "S" # Slack
    "T" # Ghostty
    "X" # Linear
    "U"
    "I" # Dia (work)
    "O"
    "P"
  ];

  # --focus-follows-window keeps focus on the window that was just moved, so
  # sending a window away also switches to it.
  workspaceBindings = lib.listToAttrs (
    lib.concatMap (
      workspace:
      let
        key = lib.toLower workspace;
      in
      [
        (lib.nameValuePair "alt-${key}" "workspace ${workspace}")
        (lib.nameValuePair "alt-shift-${key}" "move-node-to-workspace ${workspace} --focus-follows-window")
      ]
    ) workspaces
  );

  # Dialog-shaped apps that tile badly.
  floatingApps = [
    "com.apple.ActivityMonitor"
    "com.apple.systempreferences"
  ];

  # Apps that are always running, so they are worth a fixed home. Bundle ids come
  # from each app's Info.plist; `aerospace list-apps` prints them too.
  workspaceByApp = {
    "com.anthropic.claudefordesktop" = "A";
    "com.google.Chrome" = "B";
    "com.linear" = "X";
    "com.mitchellh.ghostty" = "T";
    "com.tinyspeck.slackmacgap" = "S";
    "company.thebrowser.dia" = if host.profile == "work" then "I" else "B";
    "notion.id" = "N";
  };
in
{
  services.aerospace = {
    enable = true;

    settings = {
      config-version = 2;

      # The launchd agent owns startup; the nix-darwin module asserts this is false.
      start-at-login = false;

      # A container with a single child is dissolved, and nested containers always
      # alternate orientation. Together these keep the tree shallow and predictable
      # at the cost of manual splits, which `join-with` in service mode replaces.
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      accordion-padding = 24;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      # Focusing a hidden app's window otherwise leaves it hidden and unreachable.
      automatically-unhide-macos-hidden-apps = true;

      key-mapping.preset = "qwerty";

      # Keep the pointer with the focus, so the hovered window and the focused
      # window agree and macOS scroll/hover targets follow the keyboard.
      on-focus-changed = [ "move-mouse window-lazy-center" ];
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      # Named workspaces exist even while empty, so their bindings are never a no-op.
      persistent-workspaces = workspaces;

      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.bottom = 8;
        outer.left = 8;
        outer.right = 8;
        outer.top = 8;
      };

      mode.main.binding = workspaceBindings // {
        # Layout. Commands with several arguments toggle between them on repeated
        # presses; fullscreen drops the outer gaps so it really covers the screen.
        alt-comma = "layout accordion horizontal vertical";
        alt-slash = "layout tiles horizontal vertical";
        alt-f = "fullscreen --no-outer-gaps";
        alt-shift-f = "layout floating tiling";

        # Focus, then the same keys with shift to drag the window along. Both
        # cross monitors so neither dead-ends at a screen edge. Neither wraps
        # past the last one; move nests there instead, so alt-shift still
        # splits a row.
        alt-h = "focus left --boundaries all-monitors-outer-frame";
        alt-j = "focus down --boundaries all-monitors-outer-frame";
        alt-k = "focus up --boundaries all-monitors-outer-frame";
        alt-l = "focus right --boundaries all-monitors-outer-frame";
        alt-shift-h = "move left --boundaries all-monitors-outer-frame --boundaries-action create-implicit-container";
        alt-shift-j = "move down --boundaries all-monitors-outer-frame --boundaries-action create-implicit-container";
        alt-shift-k = "move up --boundaries all-monitors-outer-frame --boundaries-action create-implicit-container";
        alt-shift-l = "move right --boundaries all-monitors-outer-frame --boundaries-action create-implicit-container";

        # `smart` resizes along the parent container's own orientation.
        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";

        # Closes the window only, never the app.
        alt-q = "close";
        alt-tab = "workspace-back-and-forth";
        alt-shift-semicolon = "mode service";
      };

      # Rare, destructive, or one-shot commands, kept off the main mode so they
      # cannot be hit by accident. Every binding returns to main mode, so the mode
      # is only ever held for a single keystroke.
      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        b = [
          "balance-sizes"
          "mode main"
        ];
        f = [
          "layout floating tiling"
          "mode main"
        ];
        r = [
          "flatten-workspace-tree"
          "mode main"
        ];
        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];

        # With flatten-containers normalization on, `split` is undone immediately;
        # `join-with` is the working way to build a nested container by hand.
        alt-shift-h = [
          "join-with left"
          "mode main"
        ];
        alt-shift-j = [
          "join-with down"
          "mode main"
        ];
        alt-shift-k = [
          "join-with up"
          "mode main"
        ];
        alt-shift-l = [
          "join-with right"
          "mode main"
        ];
      };

      # Only the first matching rule runs, so the floating rules come first.
      on-window-detected =
        map (app: {
          "if".app-id = app;
          run = [ "layout floating" ];
        }) floatingApps
        ++ lib.mapAttrsToList (app: workspace: {
          "if".app-id = app;
          run = [ "move-node-to-workspace ${workspace}" ];
        }) workspaceByApp;
    };
  };
}
