# AGENTS.md

## Communication

- Respond in Japanese.
- Write all technical artifacts in English: code comments, commit messages, PR titles and descriptions, issue bodies, documentation.

## Git

- Follow Conventional Commits for commit messages.
- Run `git push` only with my explicit approval.
- Reuse the current Herdr worktree. For a new branch, use `herdr worktree create --branch <name>`; outside Herdr, use [git-wt](https://github.com/k1LoW/git-wt): `git wt <branch>`.

## Skills

- Use installed skills when they directly apply. For public web content, prefer APIs, CLIs, and web search/open tools; use `ego-browser` for browser UI interaction.

## Workflow

- Infer clear intent and complete the requested work. Ask only when missing information could materially change the result.
- Delegate independent work when it materially improves speed or quality. Use session subagents for short tasks; use Herdr for long-lived work or another runtime, following the `herdr` skill.
- Review the diff before finishing. Run tests only when I ask for testing or verification.
