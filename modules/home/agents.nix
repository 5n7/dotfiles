# Shared agent instructions and repository skills. Keep ~/.agents/skills writable
# for external skills installed by install-agent-skills.sh. Codex and Grok scan
# it directly; claude-code.nix and opencode.nix manage the same repository skills
# for Claude Code and OpenCode. The installer adds external skills to both
# agents' directories via `gh skill`.
{ host, lib, ... }:
let
  skills = import ./agents/skills.nix { inherit host lib; };
  # Keep the parent writable for skills managed by install-agent-skills.sh.
  skillLinks = lib.mapAttrs' (
    name: source: lib.nameValuePair ".agents/skills/${name}" { inherit source; }
  ) skills;
in
{
  home.file = {
    ".agents/AGENTS.md".source = ./agents/AGENTS.md;
    ".codex/AGENTS.md".source = ./agents/AGENTS.md;
  }
  // skillLinks;
}
