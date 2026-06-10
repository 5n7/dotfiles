---
name: order
description: Reorder code elements (constants, variables, functions, methods, struct fields, enum variants, type definitions, imports, etc.) into a semantically meaningful and consistent order within files. Use as a finishing step after writing or modifying code. Trigger when user invokes /order or asks to reorder/sort/organize code elements.
user-invocable: true
---

# Code Element Ordering

Reorder code elements within files so they follow a semantically meaningful, consistent, and readable order. This is a finishing step — do not change logic, signatures, or functionality. Only move declarations and definitions.

## Scope

Determine target files from context:

- If the user specifies files, use those.
- If recent edits exist in the conversation, apply to those files.
- If the user says "all", scan the project for source files and apply broadly.

## What to Reorder

Apply ordering to all applicable element types within each file:

- **Imports/includes** — group by standard library, external, internal; alphabetize within groups
- **Constants and variables** — group by purpose/domain, then alphabetize within groups
- **Type definitions / interfaces / structs** — order by dependency (depended-upon types first), then by conceptual proximity
- **Struct/class fields** — group semantically related fields together (e.g., identity fields, then config, then state, then metadata); within groups, order by importance or lifecycle
- **Enum variants** — order by logical progression, lifecycle stage, or severity level as appropriate
- **Functions / methods** — order by:
  1. Constructors / initializers first
  2. Public before private
  3. Higher-level orchestration before lower-level helpers
  4. Lifecycle order (init → process → cleanup) when applicable
  5. Group related functions together
- **Map/object literal keys** — alphabetize or group semantically
- **Switch/match cases** — order by logical progression or frequency

## Rules

- **Never change behavior.** Only reorder declarations/definitions. Do not rename, refactor, or alter logic.
- **Respect language conventions.** Follow idiomatic ordering for the language (e.g., Go: exported before unexported; Python: module-level dunder methods first; Rust: impl blocks after struct).
- **Preserve meaningful adjacency.** If two elements are intentionally grouped (e.g., a helper directly below its caller), keep them together.
- **Minimize diff noise.** When two orderings are equally valid, prefer the one closer to the current order.

## Process

1. Read each target file.
2. Identify all reorderable element groups.
3. Determine the semantically appropriate order for each group.
4. Apply reordering via Edit tool, one file at a time.
5. After editing, briefly list what was reordered per file.
