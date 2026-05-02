---
description: Spawn a coordinated team (plan → implement → review → test) for a task
argument-hint: [task description]
---

The user wants the following task handled by a coordinated team.

**Task**: $ARGUMENTS

## Workflow

Act as coordinator. Do not edit code yourself. Execute these phases in order.

### 1. Plan

Use plan mode via `EnterPlanMode`. Build the plan **and** a **staffing** recommendation, then propose both via `ExitPlanMode`:

- **Implementers**: how many `implementer` instances and what each owns. One per independent track; a single instance is fine for small tasks.
- **Testers**: how many `tester` instances and which layer each covers (unit, integration, e2e).
- Reviewers are not staffed — review is handled by the `/code-review` skill in step 4, which orchestrates 12 specialized reviewers internally based on the diff.

### 2. Worktree

Once approved, ensure the task runs in its own worktree (per the global worktree rule: reuse if already inside one, otherwise create). When creating, name it `ship-<short task slug>`. All subsequent steps run there so implementers and testers share one workspace.

### 3. Team setup

Create a fresh agent team named `ship-<short task slug>` matching the worktree. Each run gets its own team. Spawn `implementer` and `tester` teammates per the approved staffing — these are long-lived workers you will iterate with via `SendMessage`. Do not over-staff: if the task is small, one of each is correct.

### 4. Implement

Send each `implementer` its assigned slice of the plan. If multiple, spawn them in a single message so they run in parallel. Wait for all reports.

### 5. Review

Dispatch the `/code-review` skill. It auto-detects the diff, picks core + conditional specialists by file extension, and synthesizes findings. Wait for results.

Note: `implementer` already runs fast build/lint/type-check and any quick existing tests after each edit — no separate tester invocation is needed during this loop.

### 6. Iterate (implement → review loop)

For every finding `/code-review` returns, decide one of:

- **Fix**: `SendMessage` the relevant `implementer` with the specific issue.
- **Skip with reason**: state explicitly why (false positive, out-of-scope for this task, intentional design decision, deferred to a follow-up, etc.). Never silently ignore.

Default disposition by severity:

- **Critical**: fix unless demonstrably a false positive.
- **Major**: fix unless there is a concrete reason to skip.
- **Minor**: fix when the change is cheap and the value is clear; otherwise skip with reason.

After fixes, re-dispatch `/code-review` and repeat. Exit this loop when **no Critical or Major findings remain** (all either fixed or have a recorded skip rationale with a concrete reason).

If scope expands mid-flight (new risk surfaces, a track splits further), revise staffing: spawn additional implementers as needed. Note the change to the user in the next update.

### 7. Test

Once the review loop is clean, dispatch every `tester` with the diff and what behavioral coverage to add or verify. Wait for all results.

If a tester fails or reports missing coverage, `SendMessage` the relevant `implementer` with the specific issue, then re-run `/code-review` and return to the tester — repeat until all testers pass.

### 8. Report

Summarize to the user concisely:

- **Changed**: files touched, with a one-line rationale each.
- **Review**: outcome from `/code-review` — count of fixed findings and a list of any skipped findings with their reason.
- **Tests**: outcome across all testers.
- **Open questions**: anything the user needs to decide.

Do not commit, push, or open a PR unless the user asks.
