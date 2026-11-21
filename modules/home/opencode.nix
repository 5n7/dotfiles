# OpenCode context and repository skills. The CLI comes from Homebrew on the
# personal profile. Its settings and TUI JSON stay unmanaged because OpenCode
# rewrites them at runtime.
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
