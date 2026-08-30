---
name: polish
description: Finishing pass for freshly written or edited code — runs simplify, reorders declarations, follows the repo's own style guide when one exists, then runs the project's formatter and linter. Use after finishing a non-trivial edit, on /polish, or when asked to clean up, reorder, or match repo style.
user-invocable: true
---

# Polish

A finishing pass, not a rewrite: tidy code that already works, without changing its behavior. Run the steps in order — each narrows what the next needs to worry about.

## Scope

Work out which files to touch, in this priority:

1. Files the user names explicitly.
2. Files with recent edits in the current conversation.
3. If the user says "all" (or there's no conversation context to go on), scan the project for source files.

## Step 1 — Simplify

Invoke the `simplify` skill (via the Skill tool) on the same scope. It handles reuse, redundancy, efficiency, and altitude — don't duplicate that logic here.

## Step 2 — Reorder

Reorder declarations within each file into a consistent, readable sequence. Structural only: move things, don't rename or change logic.

- Group related declarations, then order groups so dependencies come before dependents and setup comes before use.
- Within a group, prefer alphabetical or lifecycle order (init → process → cleanup), whichever the file already leans toward.
- Where the language distinguishes them, put exported/public before internal/private.
- When two orderings are equally valid, keep the one closer to the current order — minimizing diff noise beats theoretical purity. Leave deliberately adjacent pairs (a helper right below its one caller) alone.

## Step 3 — Follow the style guide

Look for docs anywhere in the repo that state a house style. If one exists, apply it — it overrides the defaults in Step 2. Skip quietly if there isn't one.

## Step 4 — Formatter and linter

Run whatever formatter and linter the project already uses, and fix anything they flag. This is the last step — the pass isn't done until they're clean.

## Wrap-up

List what changed per file in one or two lines. Skip a step from the summary entirely if it found nothing to do.
