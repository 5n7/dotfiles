# Claude Code CLI, shared memory file, and repository skills.
# install-agent-extensions.sh adds external skills and plugins outside Nix.
# settings.json stays unmanaged because Claude Code rewrites it at runtime
# (effortLevel, model, plugin toggles, hook injection).
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
    # No import for ~/.claude/rules/pstack-models.md: Claude Code loads rules itself.
    context = builtins.readFile ./agents/AGENTS.md;
    skills = import ./agents/skills.nix { inherit host lib; };
  };
}
