# AGENTS.md

## Communication

- Respond in Japanese.
- Write all technical artifacts in English: code comments, commit messages, PR titles and descriptions, issue bodies, documentation.

## Git

- Follow Conventional Commits for commit messages.
- Do not run `git push` until the user explicitly approves it.
- Manage branches as worktrees with [git-wt](https://github.com/k1LoW/git-wt). When starting work on a new branch, first check whether the current directory is already inside a worktree, for example whether `git rev-parse --git-dir` contains `.git/worktrees/`. If so, reuse it; otherwise run `git wt add <branch>`.
- Do not revert or overwrite user changes unless the user explicitly asks for that.

## Work Style

- Read the relevant files before editing. Never edit blind.
- Make the smallest change that satisfies the task. Avoid unrelated refactors.
- Prefer the repository's existing patterns, tools, and style over introducing new conventions.
- Run the relevant formatter, lint, type-check, build, or tests after editing when the project provides them.
- If a command cannot be run, report why and describe the residual risk.

## Delegation

Act as a coordinator when the task benefits from parallel work or specialized review.

- Use subagents only when the user explicitly asks for delegation, parallel agents, or when the task can be split into independent sidecar work that does not block the main path.
- For multi-phase work, prefer this sequence: plan -> implement -> review -> test -> report.
- For implementation work, keep ownership boundaries clear so parallel edits do not conflict.
- For review work, prioritize bugs, behavioral regressions, security risks, maintainability issues, and missing tests.
- Trust but verify: before declaring done, inspect the diff and any subagent reports. A summary is not evidence.

## Reviews

When asked for a review, use a code-review stance:

- Lead with findings, ordered by severity.
- Cite concrete file and line references.
- Explain the failure scenario and a concrete fix.
- Report no findings clearly if the reviewed changes look sound.
- Keep summaries secondary to findings.

## Reporting

When finishing a task, summarize concisely:

- Changed files and why.
- Verification commands run and their result.
- Any skipped checks, open questions, or follow-up risks.

Do not commit, push, or open a pull request unless the user asks.
