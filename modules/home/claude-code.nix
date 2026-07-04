# Claude Code CLI. Sources under ./claude/ drive the global ~/.claude/CLAUDE.md,
# agents, and skills via home-manager's programs.claude-code module.
# settings.json is intentionally NOT managed here: Claude Code and the Orca app
# mutate it at runtime (effortLevel, model, plugin toggles, hook injection), so
# only CLAUDE.md, agents, and skills are managed by Nix.
{ pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code-minimal;
    agentsDir = ./claude/agents;
    memory.source = ./claude/CLAUDE.md;
    skillsDir = ./claude/skills;
  };
}
