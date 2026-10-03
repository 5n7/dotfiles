---
name: create-pr
description: "Create a GitHub pull request for the current branch with a Conventional Commit title and an Intent/What/Why description. Use when the user asks to open, create, or submit a PR."
---

# Create PR

Write the title and description in English.

1. Read the whole branch against the base (`git log` and `git diff <base>...HEAD`), not just the last commit. Follow the repository's PR template if one exists. If a PR already exists for the branch, update it with `gh pr edit`.
2. Title: a simple Conventional Commit line that describes the change.
3. Description, in this order:
   - `## Intent`: the problem or goal.
   - `## What`: what changed. Add a mermaid diagram or a code outline of the changed parts when it helps.
   - `## Why`: why this approach, with trade-offs and rejected alternatives.
   - `## References`: related issues, PRs, docs, URLs, and other context. Omit if empty.
4. Invoking this skill authorizes `git push`. Push the branch if needed, then create with `gh pr create --body-file <file>`, ready for review unless a draft is requested. Return the URL.
