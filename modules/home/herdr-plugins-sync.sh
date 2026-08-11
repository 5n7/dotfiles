# shellcheck shell=bash
#
# Reconcile the herdr server's plugin registry against the set Nix declares.
# herdr.nix runs this on activation with one `id=path` pair per declared plugin;
# run it by hand with the same shape:
#
#   herdr-plugins-sync herdr-navigator=/nix/store/...-herdr-navigator-0.3.5
#
# writeShellApplication supplies the shebang and the `set -o` flags, so this file
# carries neither. The `shell` directive above is what lets shellcheck read it on
# its own — without a shebang it would otherwise bail out with SC2148.

# An empty argument list would unlink every plugin, which is never what an
# accidental invocation means.
if [ $# -eq 0 ]; then
    echo "usage: herdr-plugins-sync <id>=<path>..." >&2
    exit 2
fi

# Everything below goes through the running server. Activation runs under
# `set -eu`, so a failed `plugin link` would abort the whole `darwin-rebuild
# switch`, and the skew that causes it is self-inducing: a switch that bumps
# herdr installs the new client while the old server is still running, so the
# activation right after a version bump is exactly when the two disagree. Skip
# instead; the next activation after a `herdr server restart` reconciles.
#
# A failed command substitution leaves this empty, which is not "true", so the
# default falls into the skip branch.
health=$(herdr status --json | jq -r '.server.running and .server.compatible' || true)
if [ "$health" != "true" ]; then
    echo "herdr-plugins-sync: herdr server not running or incompatible; skipping" >&2
    exit 0
fi

declared=""
for pair in "$@"; do
    declared="${declared:+$declared }${pair%%=*}"
done

for id in $(herdr plugin list --json | jq -r '.result.plugins[].plugin_id'); do
    # Both sides are padded with spaces so the match is on a whole id: an
    # unpadded `*"$id"*` would let a declared `herdr-pilot` make an installed
    # `herdr-pi` look declared and survive the unlink.
    case " $declared " in
    *" $id "*) ;;
    *) herdr plugin unlink "$id" ;;
    esac
done

# Every declared plugin is relinked, not just the new ones: its store path
# changes whenever the plugin is rebuilt, and the registry records the path.
for pair in "$@"; do
    herdr plugin link "${pair#*=}" --enabled
done
