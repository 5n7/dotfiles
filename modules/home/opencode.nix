# OpenCode repository context and skills. The CLI is installed by Homebrew.
# settings/tui JSON files are intentionally not managed here because OpenCode
# mutates them at runtime (model, providers, TUI).
{ host, lib, ... }:
let
  skills = import ./agents/skills.nix { inherit host lib; };
  skillLinks = lib.mapAttrs' (
    name: source: lib.nameValuePair "opencode/skills/${name}" { inherit source; }
  ) skills;
in
{
  xdg.configFile = {
    "opencode/AGENTS.md".source = ./agents/AGENTS.md;
  }
  // skillLinks;
}
