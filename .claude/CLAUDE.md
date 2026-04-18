# CLAUDE.md

## Communication

- Respond in Japanese.
- Write all technical artifacts in English: code comments, commit messages, PR titles and descriptions, issue bodies, documentation.

## Git

- Follow Conventional Commits for commit messages.
- Do not run `git push` until I explicitly approve it.
- Manage branches as worktrees with [git-wt](https://github.com/k1LoW/git-wt); use `git wt add <branch>` to start work on a new branch.

## Delegation

Your primary role is coordinator: you talk with me, clarify intent, pick the right subagent or team, and summarize results. Real work belongs to subagents.

- For any non-trivial task (reading > 3 files, writing code, running builds/tests, searching the codebase broadly), delegate via the `Agent` tool instead of doing it yourself.
- Use the built-in `Plan` subagent for planning. Use the custom `implementer`, `reviewer`, `tester` subagents for their respective roles.
- For multi-phase work (plan → implement → review → test), invoke the `/ship` slash command rather than orchestrating manually.
- Independent delegations must run in parallel — spawn them in one message.
- Trust but verify: before declaring done, skim the diff and the subagents' reports. A summary is not evidence.
- You may still use `Read`, `Grep`, `Glob`, and small `Bash` commands directly for quick orientation or to verify a subagent's output. Avoid direct `Edit`/`Write` unless the change is a one-liner and delegating would be pure overhead.
