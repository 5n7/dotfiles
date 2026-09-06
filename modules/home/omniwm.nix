# OmniWM: Niri-inspired tiling window manager for macOS. https://omniwm.app
{
  config,
  lib,
  pkgs,
  ...
}:
let
  settings = import ./omniwm/settings.nix;
  settingsDirectory = "${config.xdg.configHome}/omniwm";
  settingsFile = (pkgs.formats.toml { }).generate "omniwm-settings.toml" settings;
  settingsPath = "${settingsDirectory}/settings.toml";
  settingsSchema = settings.schemaVersion;
in
{
  launchd.agents.omniwm = {
    enable = true;
    config = {
      Program = "/Applications/OmniWM.app/Contents/MacOS/OmniWM";
      RunAtLoad = true;

      # Allow quitting OmniWM without launchd immediately reopening it.
      KeepAlive = false;
    };
  };

  # Install before launchd starts OmniWM so the app never observes a partial file.
  home.activation.omniWMSettings =
    lib.hm.dag.entryBetween [ "setupLaunchAgents" ] [ "writeBoundary" ]
      ''
        settings=${lib.escapeShellArg settingsPath}
        run mkdir -p ${lib.escapeShellArg settingsDirectory}

        live_schema=""
        if [ -f "$settings" ]; then
          live_schema=$(/usr/bin/sed -nE 's/^[[:space:]]*schemaVersion[[:space:]]*=[[:space:]]*([0-9]+)[[:space:]]*$/\1/p' "$settings" | /usr/bin/head -n 1)
        fi

        if [ -n "$live_schema" ] && [ "$live_schema" -gt ${toString settingsSchema} ]; then
          echo "warning: refusing to replace OmniWM schema $live_schema with managed schema ${toString settingsSchema}" >&2
        elif ! /usr/bin/cmp -s ${settingsFile} "$settings"; then
          temporary="$settings.home-manager-new"
          run cp -f ${settingsFile} "$temporary"
          run chmod u+w "$temporary"
          run mv -f "$temporary" "$settings"
        fi
      '';
}
