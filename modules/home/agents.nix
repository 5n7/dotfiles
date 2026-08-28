# Global agent instructions shared across harnesses. modules/home/agents/AGENTS.md
# is the single source of truth; each harness gets a symlink to the same file.
# ~/.claude/CLAUDE.md is wired up in claude-code.nix via programs.claude-code.memory.
{ ... }:
{
  home.file.".agents/AGENTS.md".source = ./agents/AGENTS.md;
  home.file.".codex/AGENTS.md".source = ./agents/AGENTS.md;
  home.file.".pi/agent/AGENTS.md".source = ./agents/AGENTS.md;
}
