---
name: code-review
description: Review local changes with multiple specialist perspectives. Use when the user asks for code review, review, diff review, or pre-ship review.
---

# Multi-Perspective Code Review

Use this skill when reviewing code changes. Act as the final gatekeeper: surface only findings that are specific, verified, and actionable.

## Process

### 1. Determine Review Target

Check what changes exist:

```bash
git diff --stat
git diff --cached --stat
```

Auto-select the target:

- Only unstaged changes: review unstaged changes with `git diff`.
- Only staged changes: review staged changes with `git diff --cached`.
- Both unstaged and staged changes: ask the user which target to review.
- No local changes: review the last commit with `git diff HEAD~1`.
- No changes and no comparable commit: inform the user and stop.

### 2. Gather Context

- Read `AGENTS.md` if present.
- Read `CLAUDE.md` if present, because some repositories may still keep project standards there.
- Inspect the selected diff and changed files.
- Determine the scope, language, and purpose of the changes.
- Detect changed file types to decide which conditional perspectives apply.

### 3. Review Perspectives

Apply each relevant perspective as if it were a focused reviewer. Keep the focus narrow for each pass, then synthesize only findings that survive verification.

#### Architecture

Focus only on architecture and design.

Checklist:

- Follows established architectural patterns and layering in the codebase?
- Separation of concerns maintained: business logic, infrastructure, and presentation clearly separated?
- Unnecessary coupling introduced between modules or packages?
- Abstractions appropriate for current needs, without premature generalization?
- API and interface design clean, minimal, and hard to misuse?
- Dependencies flow in the correct direction, for example domain code not depending on infrastructure?
- Existing module boundaries respected, with no cross-cutting violations?
- New components deployable and testable independently where that matters?
- Side effects isolated and explicit, with no hidden state mutations?
- Each new module, class, or function has one clear reason to change?

Skip:

- Stylistic differences that are consistent within the project.
- Refactoring opportunities in unchanged code outside the diff.
- Abstractions that look simple but work; do not push speculative generalization.

#### Security

Focus only on security risks, aligned with OWASP-style failure modes.

Checklist:

- Authorization checks enforced on every changed endpoint, operation, query, or handler?
- User-controlled parameters checked for ownership and tenant boundaries before data access?
- No commented-out auth logic, overly permissive decorators, or accidental public exposure?
- Least privilege maintained for credentials, permissions, scopes, and service accounts?
- No debug modes, verbose errors, default credentials, or unsafe production defaults?
- Security headers, CORS, CSRF, CSP, HSTS, cookie flags, and frame protections preserved where relevant?
- New dependencies trusted, maintained, pinned appropriately, and actually necessary?
- Sensitive data protected in transit and at rest where applicable?
- No hardcoded secrets, credentials, tokens, private keys, or production URLs?
- SQL, command, path, template, LDAP, XSS, SSRF, and deserialization inputs validated or parameterized?
- Error messages and logs avoid leaking stack traces, SQL errors, file paths, tokens, PII, or internals?
- Failure modes fail closed rather than open?

Skip:

- Clearly marked example credentials in docs or fixtures.
- Hardcoded values inside tests, `testdata`, fixtures, or mock data unless they can leak into production.
- Dependency vulnerabilities that are not reachable from the diff.
- Risks already accompanied by an explicit, justified suppression such as `nosec`.

#### Performance

Focus only on realistic performance regressions.

Checklist:

- Algorithmic complexity appropriate for expected data sizes?
- Data structures match the access pattern: lookup, iteration, insertion, ordering?
- No unnecessary sorting, filtering, parsing, regex compilation, or transformation in hot paths?
- Database access avoids N+1 queries, unbounded queries, missing pagination, and unnecessary joins?
- I/O streams or buffers large payloads instead of loading entire contents into memory?
- Network calls batched, bounded, or parallelized where appropriate?
- Large allocations, copies, caches, buffers, or queues bounded and released?
- Async/concurrent work avoids blocking calls, unbounded fan-out, and needless sequential waits?
- Cache invalidation correct, with no stale-data regression?

Skip:

- Micro-optimizations with no realistic impact.
- Premature concurrency that complicates code without addressing a measured bottleneck.
- Cold paths such as one-shot scripts, migrations, or admin-only tasks unless the scale is obvious.

#### Bug & Correctness

Focus only on concrete behavioral failures.

Checklist:

- Null, nil, undefined, optional, or zero values handled correctly?
- Type assertions, casts, or narrowing cannot fail at runtime?
- Empty inputs, negative numbers, boundary values, and off-by-one cases handled?
- Unicode, multi-byte strings, escaping, and special characters handled where user input is involved?
- Errors checked, propagated with useful context, and not silently swallowed?
- Partial failures do not leave half-applied mutations or inconsistent state?
- Shared mutable state protected from races, deadlocks, and atomicity violations?
- Spawned work, subscriptions, timers, handles, and connections terminate and clean up?
- Boolean logic, branching, switch/match exhaustiveness, and default cases correct?
- Public API behavior and backward compatibility preserved unless intentionally changed?
- Floating-point comparisons and time/timezone logic avoid precision, DST, and UTC/local mistakes?

Skip:

- Defensive checks for states ruled out by types, validation, or upstream contracts.
- Theoretical edge cases that need multiple unlikely failures to coincide.
- Error-handling style differences that match the project.

#### Consistency

Focus only on consistency with the existing codebase. Do not flag formatter or linter issues.

Checklist:

- Naming conventions match surrounding code: casing, prefixes, suffixes, verb forms?
- Error handling follows existing patterns?
- Similar functionality implemented in the same way unless the change intentionally establishes a new pattern?
- Existing utilities, helpers, hooks, wrappers, or service abstractions reused instead of reimplemented?
- File and directory placement follows project conventions?
- Logging, metrics, tracing, and observability match local patterns?
- Configuration and environment variable access follow existing patterns?
- Magic numbers and strings extracted only when the codebase usually does so in similar cases?

Skip:

- Anything automatically enforced by formatter or linter.
- Personal style preferences not backed by a local pattern.
- First usage of an intentional new pattern; note it only if it creates real inconsistency risk.

#### Testing

Focus only on test coverage and test quality.

Checklist:

- New functionality and bug fixes have corresponding tests?
- Critical paths, error paths, and edge cases covered?
- Tests assert behavior rather than implementation details?
- Assertions specific enough to catch regressions?
- Test names, setup, and structure make the intent clear?
- Each test focused on one behavior?
- Table-driven or parameterized tests used when they reduce duplication without hiding intent?
- Mocks and stubs do not mask behavior that should be tested through a real boundary?
- Integration tests included for meaningful cross-boundary changes such as DB, API, filesystem, or external services?
- Flaky patterns avoided: sleeps, timing assumptions, global mutable state, test ordering dependencies?
- Cleanup handled so tests are hermetic and order-independent?

Skip:

- Extra coverage for trivial getters, setters, and pure data declarations.
- Tests that only assert framework or library behavior.
- Demands for 100% coverage where remaining branches are uninteresting guards.

#### Documentation

Focus only on documentation that prevents real confusion.

Checklist:

- Complex or non-obvious logic documented with why, not what?
- Public API docs updated for changed interfaces, parameters, return values, or errors?
- README updated if setup, configuration, usage, commands, or environment variables changed?
- Existing comments or docs now contradict the code?
- Migration steps documented for breaking changes?
- Error codes, user-facing messages, or external behavior documented for consumers?
- CHANGELOG, release notes, or migration guide updated where the project expects it?

Skip:

- Docs for obvious private helpers.
- Comments that merely restate code or type signatures.
- Documentation requests unrelated to changed behavior.

#### Maintainability

Focus only on long-term readability and changeability.

Checklist:

- Functions small enough to understand without excessive scrolling?
- Nesting shallow and control flow predictable?
- Cyclomatic complexity reasonable, with no excessive independent paths?
- Naming and structure make intent clear?
- Magic numbers, hardcoded strings, and hidden assumptions explained or named where needed?
- Abstractions operate at a consistent level within a function or module?
- New code can be modified without broad ripple effects?
- Configuration externalized where appropriate?
- Production debugging supported by useful logs, metrics, traces, or error context when relevant?
- Functions above roughly 50 lines of logic, files above roughly 500 lines, or nesting above roughly 3 levels still have a clear reason?

Skip:

- Readable code that meets the task even if further refactoring is possible.
- Refactoring opportunities in unchanged code.
- Subjective alternatives when both forms are clear.

#### Minor Issues

Focus only on low-risk issues that tools often miss.

Checklist:

- Spelling mistakes in domain terms, identifiers, comments, docs, or user-facing strings?
- Unused variables, imports, functions, files, or config left after refactoring?
- Debug artifacts left behind: `console.log`, prints, dumps, temporary flags, local paths?
- Commented-out code blocks that should be removed?
- Dead branches or unreachable code introduced?
- Outdated comments that now mislead readers?
- Copy-paste artifacts such as wrong variable names, labels, messages, or comments?
- TODO/FIXME comments without ticket, owner, date, or clear follow-up context?

Skip:

- Formatter and linter findings.
- Intentional suppressions with an explanatory comment.
- Spelling variants that match project terminology.

#### Go

Apply only when `.go` files are present in the diff. Follow Effective Go and Go Code Review Comments.

Checklist:

- Errors checked and not discarded with `_`?
- Error wrapping uses `%w` when caller needs context or unwrapping?
- `errors.Is` and `errors.As` used correctly for sentinel or typed errors?
- No bare `panic` in library code where errors should be returned?
- Error messages lowercase and without punctuation when following Go convention?
- Goroutines have clear termination paths and context cancellation where needed?
- Shared state synchronized with mutexes, channels, `sync.Once`, atomics, or other correct primitives?
- `context.Context` propagated as the first parameter for cancellable operations?
- Channel direction specified in function signatures where useful?
- `defer mu.Unlock()` placed immediately after lock acquisition unless there is a clear reason?
- Exported names have doc comments starting with the exported name?
- Interfaces small and accepted by consumers, with concrete structs returned where appropriate?
- Receiver type and receiver name consistent across methods?
- Slices preallocated when size is known or estimable?
- String construction in loops uses `strings.Builder` or equivalent?
- Large structs not copied accidentally in `range` loops or method receivers?
- Tests use table-driven style, `t.Run`, `t.Helper`, `t.Cleanup`, and `t.Parallel` where appropriate.
- Package names short, lowercase, non-plural, and dependency graph acyclic?
- `go.mod` and `go.sum` changes expected and minimal?

Skip:

- Style that `gofmt` or `golangci-lint` will handle.
- Micro-optimizations without benchmark or obvious scale.
- Idioms that match the project even if another Go style is also valid.

#### TypeScript

Apply only when `.ts` or `.tsx` files are present in the diff.

Checklist:

- Avoids `any`; uses `unknown`, generics, or precise types where needed?
- No unnecessary `as` assertions that bypass useful checking?
- Discriminated unions and type guards used for safe narrowing?
- `satisfies` used where it validates without widening?
- Strict null checks respected; no unjustified non-null assertions?
- Types and interfaces reflect domain constraints instead of loose bags of fields?
- Utility types used instead of manual redefinition when clearer?
- Generic constraints enforce real relationships?
- Return types annotated on exported functions where API clarity matters?
- `as const` used for literal or readonly data where appropriate?
- `@ts-expect-error` preferred over `@ts-ignore`, with an explanatory comment?
- Exhaustive switch or if/else paths use a `never` check for discriminated unions?
- Runtime validation used at system boundaries when static types cannot protect input?
- `readonly`, `Map`, `Set`, and immutable state patterns used where they match the data model?
- No floating promises; async errors handled intentionally?
- State shape avoids invalid combinations from multiple booleans when a union would model it better?
- Type-only imports and path aliases used consistently?
- Barrel exports do not create circular dependencies or bundle bloat?

Skip:

- Subjective `type` vs `interface` preferences.
- Type-level cleverness flags when current code is readable and correct.
- Narrowing patterns that deviate from textbook style but match project conventions.

#### Frontend

Apply only when `.tsx`, `.jsx`, `.vue`, or `.svelte` files are present in the diff.

Checklist:

- Components have a single clear responsibility?
- Props, events, slots, and children are minimal and well-defined?
- Controlled vs uncontrolled state used intentionally?
- Composition preferred over complex conditional rendering where it improves clarity?
- Shared logic extracted to hooks, composables, or local utilities when duplication becomes meaningful?
- React effects have complete dependencies and clean up subscriptions, timers, listeners, and async work?
- Derived state computed during render instead of duplicated in state?
- List keys stable and not array indexes for dynamic lists?
- Memoization used only when there is a real render-cost or identity need?
- Expensive computations not repeated on every render?
- Large lists virtualized or paginated where data size requires it?
- Images sized, lazy-loaded, and optimized where relevant?
- SSR/SSG and hydration conditions produce the same initial markup?
- Semantic HTML used before ARIA?
- Interactive elements keyboard-accessible with visible focus?
- Form inputs have labels, errors, and accessible descriptions where needed?
- Color contrast and focus indicators preserved?
- State colocated near usage; server state separated from local UI state?
- Optimistic updates roll back on failure?
- URL state used for shareable or bookmarkable UI state when appropriate?
- Styling follows project conventions, remains responsive, and avoids unnecessary `!important`?
- Loading, empty, error, and validation states are handled without exposing internals.

Skip:

- Subjective styling preferences that match the project.
- Memoization or micro-optimizations without evidence.
- Framework features the project has deliberately not adopted.

## Finding Rules

- Review only changed lines and their immediate context.
- Report only issues you are highly confident about.
- Do not report generic advice.
- Do not report issues in unrelated unchanged code.
- Do not flag a concern unless you can describe a concrete failure scenario or maintenance cost.
- Verify every candidate finding against the current source before including it.
- Discard false positives where the code or surrounding context disproves the concern.
- Deduplicate findings that share the same root cause.
- Reclassify severity based on actual impact:
  - Critical: likely production bug, data loss, security vulnerability, outage, or severe user-facing failure.
  - Major: likely future defect, meaningful maintainability problem, missing important coverage, or significant behavior risk.
  - Minor: real improvement, but the code works correctly without it.

## Output Format

Lead with findings. Omit empty severity sections.

```markdown
## Code Review Summary

**Scope**: [brief description of what was reviewed]
**Files**: [changed files reviewed]
**Assessment**: Approved / Needs Improvements / Major Issues

### Critical

- **[Category]** `file:line` - [problem]
  - Failure scenario: [specific consequence]
  - Recommendation: [concrete fix]

### Major

- **[Category]** `file:line` - [problem]
  - Failure scenario: [specific consequence]
  - Recommendation: [concrete fix]

### Minor

- **[Category]** `file:line` - [problem]
  - Impact: [specific cost]
  - Recommendation: [concrete fix]

### Positive Observations

[Include 1-2 genuinely noteworthy positives only. Omit this section if nothing stands out.]
```

If there are no findings, say that clearly and mention any tests or verification that were not run.

Do not include an action-item checklist.
