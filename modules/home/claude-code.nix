# Claude Code CLI, shared memory file, and repository skills.
# install-agent-extensions.sh adds external skills and plugins outside Nix.
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
    # setup-pstack writes its model sheet to ~/.claude/rules/pstack-models.md,
    # which Claude Code loads on its own, so no import is needed here.
    context = builtins.readFile ./agents/AGENTS.md;
    skills = import ./agents/skills.nix { inherit host lib; };
  };
}
