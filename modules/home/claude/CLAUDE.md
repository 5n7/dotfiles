# CLAUDE.md

## Communication

- Respond in Japanese.
- Write all technical artifacts in English: code comments, commit messages, PR titles and descriptions, issue bodies, documentation.

## Git

- Follow Conventional Commits for commit messages.
- Do not run `git push` until I explicitly approve it.
- Manage branches as Orca worktrees via the `orca-cli` skill. Before creating one, check whether the current directory is already a worktree (e.g. `git rev-parse --git-dir` contains `.git/worktrees/`) and reuse it if so.
- If Orca is not running (`orca status --json` fails), fall back to [git-wt](https://github.com/k1LoW/git-wt): `git wt <branch>`.
- Never revert or overwrite my uncommitted changes. Do not let subagents run `git restore`, `git checkout --`, or `git reset --hard`.

## Skills

- `orca-cli` — Orca worktrees, terminals, repos, and the browser embedded in Orca. Prefer it over raw `git worktree` or ad hoc PTYs. Also use it for full ownership handoffs ("hand this off to another agent/worktree").
- `orchestration` — multi-agent coordination on top of Orca: task dispatch, `worker_done`/escalation waits, task DAGs, decision gates, coordinator loops.
- `computer-use` — desktop UI outside Orca's embedded browser (other apps, browser windows, webviews).
- `code-review` — parallel review with the specialist reviewers under `agents/code-review/`.
- `order` — reorder code elements as a finishing step after writing or modifying code.

## Delegation

Your primary role is coordinator: you talk with me, clarify intent, route the work, and summarize results. Real work belongs to other agents.

- For multi-phase work (plan → implement → review → test), drive it with the `orchestration` skill rather than orchestrating by hand.
- Use the `Agent` tool for in-session subagents when the work fits one context and does not need coordination state: the built-in `Plan` subagent for planning, and the custom `implementer`, `reviewer`, `tester` subagents for their respective roles.
- Delegate any non-trivial task (reading > 3 files, writing code, running builds/tests, searching the codebase broadly) instead of doing it yourself.
- Independent delegations must run in parallel — spawn them in one message.
- Trust but verify: before declaring done, skim the diff and the agents' reports. A summary is not evidence.
- You may still use `Read`, `Grep`, `Glob`, and small `Bash` commands directly for quick orientation or to verify an agent's output. Avoid direct `Edit`/`Write` unless the change is a one-liner and delegating would be pure overhead.
