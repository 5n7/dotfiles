#!/usr/bin/env bash
# Install skills into ~/.agents/skills and ~/.claude/skills via `gh skill`.
# These land outside Nix, so a darwin-rebuild on a fresh machine does not bring
# them back -- re-run this there. Update later with `gh skill update --all`.
#
# Skills execute arbitrary code in the agent's environment. Read one before
# trusting it:  gh skill preview mattpocock/skills skills/productivity/grilling

set -euo pipefail

readonly AGENTS=(claude-code universal)

add_repo() { # <repo> -- every skill it publishes
    local agent
    printf '\n==> %s (all)\n' "$1"
    for agent in "${AGENTS[@]}"; do
        gh skill install "$1" --all --agent "$agent" --scope user --force
    done
}

add_skill() { # <repo> <skill-path>
    local agent
    printf '\n==> %s (%s)\n' "$2" "$1"
    for agent in "${AGENTS[@]}"; do
        gh skill install "$1" "$2" --agent "$agent" --scope user --force
    done
}

add_repo cloudflare/skills

add_skill anthropics/claude-plugins-community eli5
add_skill citrolabs/ego-lite ego-browser
add_skill cursor/plugins pstack/skills/unslop
add_skill duyet/codex-claude-plugins simplify/skills/simplify
add_skill herdrdev/herdr skills/herdr
add_skill humanlayer/skills plugins/show-me/skills/show-me
add_skill mattpocock/skills skills/engineering/domain-modeling
add_skill mattpocock/skills skills/engineering/grill-with-docs
add_skill mattpocock/skills skills/productivity/grill-me
add_skill mattpocock/skills skills/productivity/grilling
add_skill mattpocock/skills skills/productivity/writing-for-agents
add_skill pbakaus/impeccable impeccable
