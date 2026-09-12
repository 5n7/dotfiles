# OpenCode CLI and repository skills. settings/tui json are intentionally NOT
# managed here: OpenCode mutates them at runtime (model, providers, TUI).
{
  pkgs-unstable,
  ...
}:
{
  programs.opencode = {
    enable = true;
    package = pkgs-unstable.opencode;
    context = ./agents/AGENTS.md;
    skills = ./agents/skills;
  };
}
