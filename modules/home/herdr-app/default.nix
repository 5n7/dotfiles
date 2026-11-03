# Herdr desktop app, installed as a Homebrew cask. https://herdr.dev
{
  lib,
  pkgs,
  ...
}:
let
  # The app reads this fixed path under $HOME, not $XDG_CONFIG_HOME.
  appDir = ".config/herdr-app";

  json = pkgs.formats.json { };

  # The second keys of the Ctrl+F prefix: its keymap section and its card.
  prefix = import ./mods/prefix { inherit lib pkgs; };

  # keys.json replaces the app's keymap rather than extending it, so this is all
  # of it. As in the TUI, herdr's own actions go through the prefix alone.
  keymap = json.generate "herdr-app-keys.json" {
    global = {
      # Ctrl+F opens ./mods/prefix, which reads the next key as the TUI's prefix
      # did.
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

    # The terminals' font, as ghostty's: its first family, which is all the app
    # takes.
    font = "0xProto Nerd Font";
    font_size = 12;

    # Option is Alt on every input source, as with ghostty's
    # macos-option-as-alt. The default, auto, does that only on US and ABC
    # layouts.
    option_as_alt = "on";

    # Off, as DISABLE_TELEMETRY and vicinae's telemetry are.
    telemetry = false;
  };

  # The themes beyond the app's own, by the name settings.json and the picker
  # use, which is also the file name the app finds each by.
  themes = {
    tokyo-night-storm = import ./themes/tokyo-night-storm.nix;
  };
in
{
  # The app writes settings.json itself and moves keys.json aside on reset, which
  # a store symlink cannot take, so both are copied in as writable files. The app
  # reloads them live, so they change only when they differ, land by rename, and
  # wait for linkGeneration to place the theme and mod they name.
  home.activation.herdrAppConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    herdrAppInstall() {
      if ! cmp -s "$1" "$HOME/${appDir}/$2"; then
        run install -m 0644 "$1" "$HOME/${appDir}/.$2.tmp"
        run mv -f "$HOME/${appDir}/.$2.tmp" "$HOME/${appDir}/$2"
      fi
    }
    run mkdir -p "$HOME/${appDir}"
    herdrAppInstall ${keymap} keys.json
    herdrAppInstall ${settings} settings.json
  '';

  home.file = {
    # File by file, so the folder stays writable for the jsconfig.json and
    # gpui-kit.d.ts the app writes beside every mod.
    "${appDir}/mods/prefix/card.json".source = prefix.card;
    "${appDir}/mods/prefix/main.js".source = ./mods/prefix/main.js;
    "${appDir}/mods/prefix/mod.json".source = ./mods/prefix/mod.json;
  }
  // lib.mapAttrs' (
    name: theme:
    lib.nameValuePair "${appDir}/themes/${name}.json" {
      source = json.generate "herdr-app-theme-${name}.json" theme;
    }
  ) themes;
}
