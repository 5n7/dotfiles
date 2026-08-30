# Claude Code CLI. The memory file (~/.claude/CLAUDE.md) and the skills both come
# from the shared ./agents/ tree (see agents.nix), via home-manager's
# programs.claude-code module. Subagent definitions are no longer managed here.
# settings.json is intentionally NOT managed here: Claude Code mutates it at
# runtime (effortLevel, model, plugin toggles, hook injection), so only the
# memory file and skills are managed by Nix.
{ pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code-minimal;
    context = ./agents/AGENTS.md;
    skills = ./agents/skills;
  };
}
