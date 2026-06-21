# Claude Code CLI. Sources under ./claude/ drive the global ~/.claude/CLAUDE.md,
# agents, and skills via home-manager's programs.claude-code module.
{ pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code-minimal;
    settings = {
      enabledPlugins = {
        "skill-creator@claude-plugins-official" = true;
      };
      skipDangerousModePermissionPrompt = true;
      statusLine = {
        type = "command";
        command = "bunx -y ccstatusline@latest";
      };
      theme = "dark";
    };
    agentsDir = ./claude/agents;
    memory.source = ./claude/CLAUDE.md;
    skillsDir = ./claude/skills;
  };
}
