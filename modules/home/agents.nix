# Shared agent instructions and repository skills. Keep ~/.agents/skills writable
# for external skills installed by install-agent-skills.sh. Codex and Grok scan
# it directly; claude-code.nix and opencode.nix manage the same repository skills
# for Claude Code and OpenCode. The installer adds external skills to both
# agents' directories via `gh skill`.
{ lib, ... }:
let
  skills = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./agents/skills);
  # Keep the parent writable for skills managed by install-agent-skills.sh.
  skillLinks = lib.mapAttrs' (
    name: _:
    lib.nameValuePair ".agents/skills/${name}" {
      source = ./agents/skills + "/${name}";
    }
  ) skills;
in
{
  home.file = {
    ".agents/AGENTS.md".source = ./agents/AGENTS.md;
    ".codex/AGENTS.md".source = ./agents/AGENTS.md;
  }
  // skillLinks;
}
