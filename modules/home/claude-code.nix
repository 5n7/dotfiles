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
    # setup-pstack writes its per-role model sheet here and expects this import;
    # CLAUDE.md is a read-only store link, so the import lives in Nix.
    context = builtins.readFile ./agents/AGENTS.md + "\n@~/.claude/pstack-models.md\n";
    skills = import ./agents/skills.nix { inherit host lib; };
  };
}
