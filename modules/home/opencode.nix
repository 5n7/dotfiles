# OpenCode CLI and repository skills. settings/tui json are intentionally NOT
# managed here: OpenCode mutates them at runtime (model, providers, TUI).
{ ... }:
{
  programs.opencode = {
    enable = true;
    package = null;
    context = ./agents/AGENTS.md;
    skills = ./agents/skills;
  };
}
