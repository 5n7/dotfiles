---
name: mise-upgrade
description: Update all mise-managed tools to their latest versions and bump the pinned versions in mise.toml. Trigger when the user invokes /mise-upgrade or asks to "update mise tools", "upgrade mise", or "bump tool versions".
user-invocable: true
---

# Upgrade mise Tools

Update every tool managed by mise to its latest available version and record the new versions in `mise.toml`.

## Process

1. Run `mise outdated --bump` to list tools that have newer versions available. If all tools are current, report that and stop.
2. Run `mise upgrade --bump` to install the latest versions and update the pinned versions in `mise.toml`.
3. Run `git diff -- '**/.config/mise/config.toml'` (from the dotfiles root, `$DOTFILES_DIR`) to show the exact version bumps.
4. Report which tools were upgraded (name, old version → new version). If nothing changed, say so.
5. Do NOT commit automatically. Let the user decide when to commit.

## Notes

- `--bump` is required to update the version strings in `mise.toml`; without it, `mise upgrade` only installs the latest patch within the pinned range.
- If the user is not in the dotfiles directory, use `$DOTFILES_DIR` to locate `config.toml` for the diff.
- Do not touch `mise.lock` manually — `mise upgrade --bump` handles it.
