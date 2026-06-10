# Window manager helpers (jankyborders).
{ ... }:
{
  # jankyborders draws a colored border around the focused window. The
  # home-manager module writes the bordersrc config and starts the launchd
  # agent, and installs the jankyborders package itself.
  services.jankyborders = {
    enable = true;
    settings = {
      style = "round";
      width = 10.0;
      hidpi = "on";
      # The module splices settings into a bash array unquoted, so the value must
      # carry its own quotes or the parentheses break `bash -n` in the checkPhase.
      active_color = ''"gradient(top_left=0xffe0af68,bottom_right=0xfff7768e)"'';
      inactive_color = "0x00000000";
    };
  };
}
