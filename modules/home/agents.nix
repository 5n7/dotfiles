# Global agent instructions and skills shared across harnesses. modules/home/agents/
# is the single source of truth; each harness gets a symlink to the same files.
# Codex and Grok both scan ~/.agents/skills natively, so only Claude Code needs
# its own link; ~/.claude/CLAUDE.md and ~/.claude/skills are wired up in
# claude-code.nix via programs.claude-code.context and .skills.
{ ... }:
{
  home.file.".agents/AGENTS.md".source = ./agents/AGENTS.md;
  home.file.".codex/AGENTS.md".source = ./agents/AGENTS.md;
  home.file.".pi/agent/AGENTS.md".source = ./agents/AGENTS.md;

  # recursive = true symlinks each SKILL.md individually and leaves the
  # intermediate directories writable, so harness-written files can coexist.
  home.file.".agents/skills" = {
    source = ./agents/skills;
    recursive = true;
  };
}
