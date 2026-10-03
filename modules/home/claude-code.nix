# Claude Code CLI, shared memory file, and repository skills.
# install-agent-skills.sh adds external skills to ~/.claude/skills via `gh skill`.
# settings.json is intentionally NOT managed here: Claude Code mutates it at
# runtime (effortLevel, model, plugin toggles, hook injection).
{
  host,
  lib,
  pkgs,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code-minimal;
    context = ./agents/AGENTS.md;
    skills = import ./agents/skills.nix { inherit host lib; };
  };
}
