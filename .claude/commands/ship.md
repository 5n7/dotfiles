---
description: Spawn a coordinated team (plan → implement → review → test) for a task
argument-hint: [task description]
---

The user wants the following task handled by a coordinated team.

**Task**: $ARGUMENTS

## Workflow

Act as coordinator. Do not edit code yourself. Execute these phases in order:

### 1. Plan

Spawn the built-in `Plan` subagent to design an implementation plan. Pass the task plus any relevant context you already have.

Alongside the plan, have `Plan` propose a **staffing** recommendation:

- **Implementers**: how many `implementer` instances and what each owns. One per independent track; a single instance is fine for small tasks.
- **Reviewers**: which reviewer roles are needed. Always include `reviewer`, plus any built-in specialist (`code-review:security`, `code-review:performance`, `code-review:architecture`, `code-review:bug-correctness`, etc.) warranted by risk.
- **Testers**: how many `tester` instances and which layer each covers (unit, integration, e2e).

Present the plan **and the staffing** to the user. Wait for approval. If the user redirects, loop back to `Plan`.

### 2. Team setup

Once approved, create (or reuse) an agent team named `ship-team`. Spawn teammates per the approved staffing. Do not over-staff — if the task is small, one of each is correct.

### 3. Implement

Send each `implementer` its assigned slice of the plan. If multiple, spawn them in a single message so they run in parallel. Wait for all reports.

### 4. Review and test in parallel

In a single message, dispatch the diff to every reviewer (general `reviewer` plus any specialists) and every `tester`. They all run concurrently.

### 5. Iterate

If any reviewer returns **Must fix** findings, or any `tester` reports failures, loop back to the relevant `implementer` with the specific issues. Repeat until every reviewer and tester signals clean.

If the scope expands mid-flight (new risk surfaces, a track turns out to split further), revise staffing: spawn additional implementers, reviewers, or testers as needed. Note the change to the user in the next update.

### 6. Report

Summarize to the user in 3–5 lines:

- **Changed**: files touched, with a one-line rationale each.
- **Review**: outcome across all reviewers.
- **Tests**: outcome across all testers.
- **Open questions**: anything the user needs to decide.

Do not commit, push, or open a PR unless the user asks.
