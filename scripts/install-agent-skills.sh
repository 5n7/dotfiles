#!/usr/bin/env bash
# Install agent skills into ~/.agents/skills via `gh skill`.
# These land outside Nix, so a darwin-rebuild on a fresh machine does not bring
# them back -- re-run this there. Update later with `gh skill update --all`.
#
# Skills execute arbitrary code in the agent's environment. Read one before
# trusting it:  gh skill preview mattpocock/skills skills/productivity/grilling

set -euo pipefail

readonly AGENT=universal

add_repo() { # <repo> -- every skill it publishes
    printf '\n==> %s (all)\n' "$1"
    gh skill install "$1" --all --agent "$AGENT" --scope user --force
}

add_skill() { # <repo> <skill-path>
    printf '\n==> %s (%s)\n' "$2" "$1"
    gh skill install "$1" "$2" --agent "$AGENT" --scope user --force
}

add_repo cloudflare/skills

add_skill anthropics/claude-plugins-community eli5
add_skill citrolabs/ego-lite ego-browser
add_skill cursor/plugins pstack/skills/unslop
add_skill duyet/codex-claude-plugins simplify/skills/simplify
add_skill humanlayer/skills plugins/show-me/skills/show-me
add_skill mattpocock/skills skills/engineering/domain-modeling
add_skill mattpocock/skills skills/engineering/grill-with-docs
add_skill mattpocock/skills skills/productivity/grill-me
add_skill mattpocock/skills skills/productivity/grilling
add_skill mattpocock/skills skills/productivity/writing-for-agents
add_skill pbakaus/impeccable impeccable
