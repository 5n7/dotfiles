#!/usr/bin/env bash
# Install skills into ~/.agents/skills and ~/.claude/skills via `gh skill`.
# These land outside Nix, so a darwin-rebuild on a fresh machine does not bring
# them back -- re-run this there. Update later with `gh skill update --all`.
#
# Skills execute arbitrary code in the agent's environment. Read one before
# trusting it:  gh skill preview mattpocock/skills skills/productivity/grilling
#
# Installs run in parallel (MAX_JOBS at a time, default 8); each one's output
# is buffered and printed in order once everything has finished.

set -euo pipefail

readonly AGENTS=(claude-code universal)
readonly MAX_JOBS=${MAX_JOBS:-8}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
labels=()

spawn() { # <label> <gh skill install args...> -- one job per agent
    local label=$1 agent log
    shift
    for agent in "${AGENTS[@]}"; do
        log="$tmpdir/${#labels[@]}"
        labels+=("$label [$agent]")
        while (($(jobs -rp | wc -l) >= MAX_JOBS)); do
            wait -n || true
        done
        (
            rc=0
            gh skill install "$@" --agent "$agent" --scope user --force \
                >"$log" 2>&1 || rc=$?
            echo "$rc" >"$log.rc"
        ) &
    done
}

add_repo() { # <repo> -- every skill it publishes
    spawn "$1 (all)" "$1" --all
}

add_skill() { # <repo> <skill-path>
    spawn "$2 ($1)" "$1" "$2"
}

add_repo cloudflare/skills

add_skill anthropics/claude-plugins-community eli5
add_skill ayghri/i-have-adhd skills/i-have-adhd
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

wait

failed=()
for i in "${!labels[@]}"; do
    printf '\n==> %s\n' "${labels[i]}"
    cat "$tmpdir/$i"
    [[ $(<"$tmpdir/$i.rc") == 0 ]] || failed+=("${labels[i]}")
done

if ((${#failed[@]})); then
    printf '\nFailed:\n' >&2
    printf '  %s\n' "${failed[@]}" >&2
    exit 1
fi
