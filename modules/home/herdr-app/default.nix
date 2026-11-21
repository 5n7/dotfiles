# Herdr desktop app, installed as a Homebrew cask. https://herdr.dev
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # The app reads this fixed path under $HOME, not $XDG_CONFIG_HOME.
  appDir = ".config/herdr-app";

  json = pkgs.formats.json { };

  extensions = inputs.herdr-extensions.packages.${pkgs.stdenv.hostPlatform.system};

  prefix = extensions.mod-prefix.override { groups = import ./prefix-keys.nix { inherit lib; }; };

  mods = {
    pick = extensions.mod-pick;
    inherit prefix;
    usage = extensions.mod-usage;
  };

  # A name becomes a folder that ./mods-sync.sh replaces wholesale, so "." or
  # ".." would reach outside mods/.
  modsManifest = json.generate "herdr-app-mods.json" (
    lib.mapAttrs (
      name: mod:
      assert lib.assertMsg (
        builtins.match "[A-Za-z0-9_-][A-Za-z0-9_.-]*" name != null
      ) "herdr-app mod name ${name} is not a plain folder name";
      assert lib.assertMsg (mod.modName or name == name) ''
        herdr-app mod ${name} expects to be installed as ${mod.modName}
      '';
      "${mod}"
    ) mods
  );

  herdr-app-mods-sync = pkgs.writeShellApplication {
    name = "herdr-app-mods-sync";
    runtimeInputs = [
      pkgs.jq
      pkgs.rsync
    ];
    text = builtins.readFile ./mods-sync.sh;
  };

  # keys.json replaces the app's keymap rather than extending it, so this is all
  # of it. As in the TUI, herdr's own actions go through the prefix alone.
  keymap = json.generate "herdr-app-keys.json" {
    global = {
      "ctrl-f" = "mod.open:prefix";

      # Standard Mac shortcuts, kept direct rather than behind the prefix.
      "cmd-," = "app.settings";
      "cmd-q" = "app.quit";
    };

    terminal = {
      # The prefix again, since this section wins over global while a terminal
      # has focus.
      "ctrl-f" = "mod.open:prefix";

      # Clipboard. Cmd+V pastes an image alone too, so the app's Ctrl+V is left
      # to VoiceInk, which takes it before any app sees it.
      "cmd-c" = "terminal.copy";
      "cmd-v" = "terminal.paste";
    };

    # While the prefix waits.
    "mod:prefix" = prefix.keymap;
  };

  # Only the values that differ from the app's defaults.
  settings = json.generate "herdr-app-settings.json" {
    # Always dark, as ghostty is: a theme picked per appearance shows its dark
    # half even on a light system.
    appearance = "dark";
    theme = "tokyo-night-storm";

    # ghostty's first font family; the app takes only one.
    font = "0xProto Nerd Font";
    font_size = 12;

    # Option is Alt on every input source, as with ghostty's
    # macos-option-as-alt. The default, auto, does that only on US and ABC
    # layouts.
    option_as_alt = "on";

    telemetry = false;
  };

  # Layouts of our own, by the name `layout.switch` and the picker use. The
  # app's own are replaced on every start, so changes go in these instead.
  # `herdr-app do layout.switch '{"name":"custom"}'` shows one once, and the app
  # remembers it.
  layouts = {
    custom = import ./layouts/custom.nix;
  };

  # Each name is the theme's file name and the name settings.json uses.
  themes = {
    tokyo-night-storm = import ./themes/tokyo-night-storm.nix;
  };
in
{
  # The app writes settings.json itself and moves keys.json aside on reset, which
  # a store symlink cannot take, so both are copied in as writable files, as are
  # the layouts, which layout.set rewrites. The app reloads them live, so they
  # change only when they differ, land by rename, and wait for the theme and
  # mods they name: linkGeneration places the theme, and the mods are copied in
  # first (see ./mods-sync.sh).
  home.activation.herdrAppConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    # $2 is a path under the app's folder; the hidden temporary file sits beside
    # it, as the app ignores hidden files.
    herdrAppInstall() {
      dest="$HOME/${appDir}/$2"
      tmp="$(dirname "$dest")/.$(basename "$dest").tmp"
      if ! cmp -s "$1" "$dest"; then
        run install -m 0644 "$1" "$tmp"
        run mv -f "$tmp" "$dest"
      fi
    }
    run mkdir -p "$HOME/${appDir}"
    run ${lib.getExe herdr-app-mods-sync} "$HOME/${appDir}/mods" ${modsManifest}
    herdrAppInstall ${keymap} keys.json
    herdrAppInstall ${settings} settings.json
    run mkdir -p "$HOME/${appDir}/layouts"
    ${lib.concatLines (
      lib.mapAttrsToList (
        name: layout:
        "herdrAppInstall ${json.generate "herdr-app-layout-${name}.json" layout} layouts/${name}.json"
      ) layouts
    )}
  '';

  home.file = lib.mapAttrs' (
    name: theme:
    lib.nameValuePair "${appDir}/themes/${name}.json" {
      source = json.generate "herdr-app-theme-${name}.json" theme;
    }
  ) themes;
}
