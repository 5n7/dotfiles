# Global agent instructions and skills shared across harnesses. modules/home/agents/
# is the single source of truth; each harness gets a symlink to the same files.
# Codex and Grok both scan ~/.agents/skills natively, so only Claude Code needs
# its own link; ~/.claude/CLAUDE.md and ~/.claude/skills are wired up in
# claude-code.nix via programs.claude-code.context and .skills.
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
    ".pi/agent/AGENTS.md".source = ./agents/AGENTS.md;
  }
  // skillLinks;
}
