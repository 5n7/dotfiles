# OpenCode repository context and skills. The CLI is installed by Homebrew.
# settings/tui JSON files are intentionally not managed here because OpenCode
# mutates them at runtime (model, providers, TUI).
{ ... }:
{
  xdg.configFile = {
    "opencode/AGENTS.md".source = ./agents/AGENTS.md;
    "opencode/skills" = {
      source = ./agents/skills;
      recursive = true;
    };
  };
}
