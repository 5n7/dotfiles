# Shared agent instructions and repository skills. Skills are linked one by one so
# ~/.agents/skills stays writable: install-agent-extensions.sh adds external skills
# there and to ~/.claude/skills via `gh skill`. Codex and Grok read it directly;
# claude-code.nix and opencode.nix link the repository skills for their agents.
{ host, lib, ... }:
let
  skills = import ./agents/skills.nix { inherit host lib; };
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
