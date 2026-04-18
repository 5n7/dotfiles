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

Once approved, create a fresh agent team named `ship-<short task slug>` (e.g. `ship-add-login`, `ship-fix-race`). Each run gets its own team — never reuse a previous team or `rm -rf` its directory. Spawn `implementer` and `tester` teammates per the approved staffing — these are long-lived workers you will iterate with via `SendMessage`. Do not over-staff: if the task is small, one of each is correct.

### 3. Implement

Send each `implementer` its assigned slice of the plan. If multiple, spawn them in a single message so they run in parallel. Wait for all reports.

### 4. Review and test in parallel

In a single message, dispatch both:

- The `/code-review` skill (it auto-detects the diff, picks core + conditional specialists by file extension, and synthesizes findings)
- Every `tester` with the diff and what to verify

These run concurrently. Wait for all results.

### 5. Iterate

For every finding `/code-review` returns and every `tester` failure, decide one of:

- **Fix**: `SendMessage` the relevant `implementer` with the specific issue.
- **Skip with reason**: state explicitly why (false positive, out-of-scope for this task, intentional design decision, deferred to a follow-up, etc.). Never silently ignore.

Default disposition by severity:

- **Critical**: fix unless demonstrably a false positive.
- **Major**: fix unless there is a concrete reason to skip.
- **Minor**: fix when the change is cheap and the value is clear; otherwise skip with reason.

Repeat from step 4 until every finding is either resolved or has a recorded skip rationale, and all testers pass.

If scope expands mid-flight (new risk surfaces, a track splits further), revise staffing: spawn additional implementers or testers as needed. Note the change to the user in the next update.

### 6. Report

Summarize to the user concisely:

- **Changed**: files touched, with a one-line rationale each.
- **Review**: outcome from `/code-review` — count of fixed findings and a list of any skipped findings with their reason.
- **Tests**: outcome across all testers.
- **Open questions**: anything the user needs to decide.

Do not commit, push, or open a PR unless the user asks.
