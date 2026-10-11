# Nix setup

Clone to `~/src/github.com/5n7/dotfiles` (the nvim config is symlinked from
there via `mkOutOfStoreSymlink`).

Two profiles: `.#personal` and `.#work`.

## Bootstrap

Apple Silicon, multi-user Nix already installed:

```sh
nix --extra-experimental-features 'nix-command flakes' \
  run nix-darwin -- switch --flake .#personal
```

The first `switch` renames existing dotfile symlinks to `*.backup`; remove
them once things look healthy. Then start the container runtime once:

```sh
colima start
```

## Day-to-day

```sh
darwin-rebuild switch --flake .#personal     # apply changes
darwin-rebuild build  --flake .#personal     # dry build
darwin-rebuild --rollback                    # undo last switch
darwin-rebuild --list-generations
```

## Agent plugins and skills

Run `scripts/install-agent-extensions.sh` after setup to install Claude Code
plugins through `claude plugin`, and the same external skills into
`~/.agents/skills` and `~/.claude/skills` through `gh skill`.
Nix manages the repository skills in both directories.
Run `/pstack:setup-pstack` once in Claude Code to write the model sheet that
`~/.claude/CLAUDE.md` imports. Update plugins with `claude plugin marketplace update`
and `claude plugin update <plugin>`, and skills with `gh skill update --all`.

## Update everything

```sh
NIX_CONFIG="access-tokens = github.com=`gh auth token`" nix flake update

sudo -H NIX_CONFIG="access-tokens = github.com=`gh auth token`" \
  nix --extra-experimental-features 'nix-command flakes' \
  run nix-darwin -- switch --flake .#personal
```

The token avoids GitHub's API rate limit while fetching flake inputs. Homebrew
packages upgrade on `switch`; Mac App Store apps need `mas upgrade` separately.
