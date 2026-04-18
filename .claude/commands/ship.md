---
description: Spawn a coordinated team (plan → implement → review → test) for a task
argument-hint: [task description]
---

The user wants the following task handled by a coordinated team.

**Task**: $ARGUMENTS

## Workflow

Act as coordinator. Do not edit code yourself. Execute these phases in order.

### 1. Plan

Spawn the built-in `Plan` subagent to design an implementation plan. Pass the task plus any relevant context you already have.

Alongside the plan, have `Plan` propose a **staffing** recommendation:

- **Implementers**: how many `implementer` instances and what each owns. One per independent track; a single instance is fine for small tasks.
- **Testers**: how many `tester` instances and which layer each covers (unit, integration, e2e).

Reviewers are not staffed — review is handled by the `/code-review` skill in step 4, which orchestrates 12 specialized reviewers internally based on the diff.

Present the plan **and the staffing** to the user. Wait for approval. If the user redirects, loop back to `Plan`.

### 2. Team setup

Once approved, create (or reuse) an agent team named `ship-team`. Spawn `implementer` and `tester` teammates per the approved staffing — these are long-lived workers you will iterate with via `SendMessage`. Do not over-staff: if the task is small, one of each is correct.

### 3. Implement

Send each `implementer` its assigned slice of the plan. If multiple, spawn them in a single message so they run in parallel. Wait for all reports.

### 4. Review and test in parallel

In a single message, dispatch both:

- The `/code-review` skill (it auto-detects the diff, picks core + conditional specialists by file extension, and synthesizes findings)
- Every `tester` with the diff and what to verify

These run concurrently. Wait for all results.

### 5. Iterate

If `/code-review` returns **Critical** findings, or any `tester` reports failures, `SendMessage` the relevant `implementer` with the specific issues. Repeat from step 4 until both signal clean.

If scope expands mid-flight (new risk surfaces, a track splits further), revise staffing: spawn additional implementers or testers as needed. Note the change to the user in the next update.

### 6. Report

Summarize to the user in 3–5 lines:

- **Changed**: files touched, with a one-line rationale each.
- **Review**: outcome from `/code-review`.
- **Tests**: outcome across all testers.
- **Open questions**: anything the user needs to decide.

Do not commit, push, or open a PR unless the user asks.
