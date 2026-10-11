#!/usr/bin/env bash
# Install Claude Code plugins via `claude plugin`, and skills into
# ~/.agents/skills and ~/.claude/skills via `gh skill`. These land outside Nix,
# so a darwin-rebuild on a fresh machine does not bring them back -- re-run
# this there. Update later with `claude plugin marketplace update`,
# `claude plugin update <plugin>`, and `gh skill update --all`.
#
# Plugins and skills execute arbitrary code in the agent's environment. Read
# one before trusting it: browse a plugin's marketplace repo, or
#   gh skill preview mattpocock/skills skills/productivity/grilling
#
# Plugin installs run one at a time because they all write settings.json; skill
# installs then run in parallel (MAX_JOBS at a time, default 8). Each one's
# output is buffered and printed in order once everything has finished.

set -euo pipefail

readonly AGENTS=(claude-code universal)
readonly MAX_JOBS=${MAX_JOBS:-8}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
labels=()

track() { # <label> -- register a label and point the caller's $log at its slot
    log="$tmpdir/${#labels[@]}"
    labels+=("$1")
}

run() { # <log> <command...> -- buffer output and exit status for the summary
    local log=$1 rc=0
    shift
    "$@" >"$log" 2>&1 || rc=$?
    echo "$rc" >"$log.rc"
}

add_plugin() { # <marketplace-repo> <plugin>
    local log
    track "$2 ($1)"
    run "$log" claude plugin install "$2" --marketplace "$1"
}

spawn() { # <label> <gh skill install args...> -- one job per agent
    local label=$1 agent log
    shift
    for agent in "${AGENTS[@]}"; do
        track "$label [$agent]"
        while (($(jobs -rp | wc -l) >= MAX_JOBS)); do
            wait -n || true
        done
        run "$log" gh skill install "$@" --agent "$agent" --scope user --force &
    done
}

add_skill_repo() { # <repo> -- every skill it publishes
    spawn "$1 (all)" "$1" --all
}

add_skill() { # <repo> <skill-path>
    spawn "$2 ($1)" "$1" "$2"
}

# TODO: install pstack for Codex and the other agents too (Codex has `codex plugin
# marketplace add` and `codex plugin add`); AGENTS.md's PR rule points at it.
add_plugin anthropics/claude-plugins-official plugin-dev
add_plugin michael-denyer/pstack-claude pstack

add_skill_repo cloudflare/skills

# ego-browser is not listed: the ego lite app links its bundled copy into each
# agent's skills directory and updates it with the app, so `gh skill` cannot
# write through that link.
add_skill ayghri/i-have-adhd skills/i-have-adhd
add_skill herdrdev/herdr skills/herdr
add_skill humanlayer/skills plugins/show-me/skills/show-me
add_skill mattpocock/skills skills/engineering/domain-modeling
add_skill mattpocock/skills skills/engineering/grill-with-docs
add_skill mattpocock/skills skills/productivity/grilling
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
