# Claude Code CLI. The memory file (~/.claude/CLAUDE.md) comes from the shared
# ./agents/AGENTS.md (see agents.nix); agents and skills come from ./claude/,
# all via home-manager's programs.claude-code module.
# settings.json is intentionally NOT managed here: Claude Code and the Orca app
# mutate it at runtime (effortLevel, model, plugin toggles, hook injection), so
# only the memory file, agents, and skills are managed by Nix.
{ pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code-minimal;
    agentsDir = ./claude/agents;
    memory.source = ./agents/AGENTS.md;
    skillsDir = ./claude/skills;
  };
}
