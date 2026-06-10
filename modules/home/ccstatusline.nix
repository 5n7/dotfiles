# ccstatusline statusline for Claude Code, invoked via `bunx ccstatusline` from
# claude-code.nix's statusLine. The settings file and the custom widget scripts
# it references live under ./ccstatusline.
{ config, ... }:
{
  # settings.json carries \u escapes (defaultSeparator) that a Nix attrset cannot
  # express, so keep it as JSON and template the per-host config path in: each
  # commandPath is @configHome@/ccstatusline/<script>.sh.
  xdg.configFile."ccstatusline/settings.json".text =
    builtins.replaceStrings [ "@configHome@" ] [ config.xdg.configHome ]
      (builtins.readFile ./ccstatusline/settings.json);

  # Shared, sourced by the widgets — no exec bit.
  xdg.configFile."ccstatusline/lib.sh".source = ./ccstatusline/lib.sh;

  # ccstatusline executes each widget commandPath directly, so the exec bit is required.
  xdg.configFile."ccstatusline/context-bar.sh" = {
    source = ./ccstatusline/context-bar.sh;
    executable = true;
  };
  xdg.configFile."ccstatusline/cwd-path.sh" = {
    source = ./ccstatusline/cwd-path.sh;
    executable = true;
  };
  xdg.configFile."ccstatusline/model-color.sh" = {
    source = ./ccstatusline/model-color.sh;
    executable = true;
  };
  xdg.configFile."ccstatusline/status-claude.sh" = {
    source = ./ccstatusline/status-claude.sh;
    executable = true;
  };
}
