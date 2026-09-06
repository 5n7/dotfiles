# AGENTS.md

## Communication

- Respond in Japanese.
- Write all technical artifacts in English: code comments, commit messages, PR titles and descriptions, issue bodies, documentation.

## Git

- Follow Conventional Commits for commit messages.
- Run `git push` only with my explicit approval.
- Manage branches as herdr worktrees: `herdr worktree create --branch <name>`. Reuse the current directory when it is already a worktree. Outside herdr, fall back to [git-wt](https://github.com/k1LoW/git-wt): `git wt <branch>`.

## Skills

- Use installed skills listed by your agent environment.
- Prefer APIs, CLIs, and built-in web search/open tools for public web content. Use `ego-browser` only for browser UI interaction such as authentication, form entry, clicking controls, screenshots, or UI testing.

## Delegation

Coordinate the work: clarify intent with me, delegate tasks, and summarize results.

- Delegate non-trivial tasks, including reading more than three files, writing code, running builds or tests, and broad codebase searches.
- Prefer available subagents or roles such as plan, implement, review, and test. If none are available, plan, implement, and review the diff yourself.
- Dispatch independent tasks in parallel in one message.
- Drive each phase of plan → implement → review → test and report between phases.
- Use a herdr pane for work that needs a long-lived terminal, a different agent or runtime, or must continue while we talk. Use `herdr agent start`, `herdr agent prompt --wait`, and `herdr agent wait --until blocked`. Keep work that fits one context in the current session's subagents.
- Start Codex agents through herdr normally to inherit the configured sandbox and automatic approval review. Start other agents with their native skip-approvals flag after `--` to avoid permission prompts. Use `--dangerously-skip-permissions` for Claude and `--always-approve` for Grok, for example `herdr agent start <name> --kind claude --pane <id> -- --dangerously-skip-permissions`. Use the equivalent flag for other agents, or start normally if none exists.
- Before declaring completion, inspect the diff and agent reports.
- Read, search, or run small shell commands directly for orientation or verification. Limit direct edits to one-liners when delegation would add only overhead.
