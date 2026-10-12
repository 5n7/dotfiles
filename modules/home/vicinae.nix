# Vicinae launcher, installed as a Homebrew cask. https://vicinae.com
# The app registers its own login item on first launch.
{
  config,
  dotfilesDir,
  lib,
  ...
}:
let
  # Vicinae hardcodes these XDG-style paths on macOS instead of reading XDG_* variables.
  configDirectory = "${config.home.homeDirectory}/.config/vicinae";
  userSettingsPath = "${configDirectory}/settings.json";
  userSettingsSeed = builtins.toFile "vicinae-settings.json" (
    builtins.toJSON { imports = [ "nix.json" ]; }
  );
in
{
  # Vicinae saves settings.json by renaming a temporary file over it, which would
  # replace a symlink. It stays a writable file that imports the read-only nix.json,
  # and keys set in the GUI override nix.json. nix.json holds only values that differ
  # from Vicinae's defaults (`vicinae config default`).
  home.file.".config/vicinae/nix.json".text = builtins.toJSON {
    # OmniWM leaves Option+Q unassigned for the snippets shortcut.
    providers.clipboard.entrypoints.history.shortcut = "alt+c";
    providers.snippets.entrypoints.manage.shortcut = "alt+q";

    close_on_focus_loss = true;
    pop_to_root_on_close = true;

    # Search the Japanese IME's composing text before it is committed.
    consider_preedit = true;

    # Match Ghostty and herdr, which use TokyoNight Storm in either system appearance.
    theme = {
      light.name = "tokyo-night-storm";
      dark.name = "tokyo-night-storm";
    };

    # Numen is the default; the macOS build also bundles SoulverCore.
    providers.calculator.preferences.backend = "soulver-core";

    telemetry.system_info = false;
  };

  home.activation.vicinaeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings=${lib.escapeShellArg userSettingsPath}
    if [ ! -e "$settings" ]; then
      run mkdir -p ${lib.escapeShellArg configDirectory}
      run cp ${userSettingsSeed} "$settings"
      run chmod u+w "$settings"
    elif ! /usr/bin/grep -q '"nix.json"' "$settings"; then
      echo "warning: $settings does not import nix.json; add \"nix.json\" to its imports" >&2
    fi
  '';

  # Vicinae writes snippets.json in place, so snippets created in the GUI go through
  # the symlink into the checkout.
  home.file.".local/share/vicinae/snippets/snippets.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/modules/home/vicinae/snippets.json";
}
