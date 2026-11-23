# OmniWM: Niri-inspired tiling window manager for macOS. https://omniwm.app
{
  config,
  lib,
  pkgs,
  ...
}:
let
  toml = pkgs.formats.toml { };
  settings = import ./omniwm/settings.nix;
  settingsDirectory = "${config.xdg.configHome}/omniwm";
  settingsFile = toml.generate "omniwm-settings.toml" settings;
  settingsPath = "${settingsDirectory}/settings.toml";
  settingsSchema = settings.schemaVersion;
  shellFile = toml.generate "omniwm-shell.toml" (import ./omniwm/shell.nix settings);
  shellPath = "${settingsDirectory}/shell/shell.toml";
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
        # Copy rather than link: OmniWM saves Settings edits back into these files.
        install_omniwm_file() {
          if ! /usr/bin/cmp -s "$1" "$2"; then
            run mkdir -p "$(dirname "$2")"
            run cp -f "$1" "$2.home-manager-new"
            run chmod u+w "$2.home-manager-new"
            run mv -f "$2.home-manager-new" "$2"
          fi
        }

        settings=${lib.escapeShellArg settingsPath}

        live_schema=""
        if [ -f "$settings" ]; then
          live_schema=$(/usr/bin/sed -nE 's/^[[:space:]]*schemaVersion[[:space:]]*=[[:space:]]*([0-9]+)[[:space:]]*$/\1/p' "$settings" | /usr/bin/head -n 1)
        fi

        if [ -n "$live_schema" ] && [ "$live_schema" -gt ${toString settingsSchema} ]; then
          echo "warning: refusing to replace OmniWM schema $live_schema with managed schema ${toString settingsSchema}" >&2
        else
          install_omniwm_file ${settingsFile} "$settings"
        fi

        install_omniwm_file ${shellFile} ${lib.escapeShellArg shellPath}
      '';
}
