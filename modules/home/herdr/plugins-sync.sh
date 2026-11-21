# shellcheck shell=bash
#
# Reconcile the herdr server's plugin registry against the manifest herdr.nix
# generates:
#
#   herdr-plugins-sync /nix/store/...-herdr-plugins-manifest.json
#
# writeShellApplication supplies the shebang and the `set -o` flags. Without a
# shebang, the `shell` directive above keeps shellcheck from failing with SC2148.

if [ $# -ne 1 ]; then
    echo "usage: herdr-plugins-sync <manifest.json>" >&2
    exit 2
fi
manifest=$1
# An empty manifest would make every installed plugin look stale.
if ! jq -e 'length > 0' "$manifest" >/dev/null; then
    echo "herdr-plugins-sync: invalid or empty manifest: $manifest" >&2
    exit 2
fi

# Activation runs under `set -eu`, so a failed `plugin link` would abort the
# whole `darwin-rebuild switch`. A switch that bumps herdr installs the new
# client while the old server still runs, so the two disagree exactly then. Skip
# instead; the next activation after a `herdr server restart` reconciles. A
# failed status call leaves `health` empty, which also skips.
health=$(herdr status --json | jq -r '.server.running and .server.compatible' || true)
if [ "$health" != "true" ]; then
    echo "herdr-plugins-sync: herdr server not running or incompatible; skipping" >&2
    exit 0
fi

installed=$(herdr plugin list --json | jq -r '.result.plugins[].plugin_id')

# Every declared plugin is relinked, not just the new ones: its store path
# changes whenever the plugin is rebuilt, and the registry records the path.
# Link first so a failed update leaves the existing registry entries intact.
while IFS=$'\t' read -r id path enabled; do
    if [ "$enabled" = "true" ]; then
        herdr plugin link "$path"
        herdr plugin enable "$id"
    else
        herdr plugin link "$path" --disabled
        herdr plugin disable "$id"
    fi
done < <(jq -r 'to_entries[] | [.key, .value.path, (.value.enabled | tostring)] | @tsv' "$manifest")

# Unlink only after every declared plugin has linked. The manifest owns the
# whole registry, so plugins installed or linked by hand are removed too.
for id in $installed; do
    if ! jq -e --arg id "$id" 'has($id)' "$manifest" >/dev/null; then
        herdr plugin unlink "$id"
    fi
done
