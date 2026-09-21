# shellcheck shell=bash
#
# Reconcile the herdr server's plugin registry against the set Nix declares.
# herdr.nix runs this on activation with a generated JSON manifest; run it by
# hand with the same shape:
#
#   herdr-plugins-sync /nix/store/...-herdr-plugins-manifest.json
#
# writeShellApplication supplies the shebang and the `set -o` flags, so this file
# carries neither. The `shell` directive above is what lets shellcheck read it on
# its own — without a shebang it would otherwise bail out with SC2148.

# Refuse missing, invalid, or empty manifests before contacting the server. An
# empty catalog would otherwise make every installed plugin look stale.
if [ $# -ne 1 ]; then
    echo "usage: herdr-plugins-sync <manifest.json>" >&2
    exit 2
fi
manifest=$1
if ! jq -e '
    .version == 1 and
    (.plugins | type == "object") and
    (.plugins | length > 0) and
    ([.plugins | to_entries[] |
        (.key | type == "string" and length > 0) and
        (.value | type == "object") and
        (.value.path | type == "string" and length > 0) and
        (.value.enabled | type == "boolean")
    ] | all)
' "$manifest" >/dev/null; then
    echo "herdr-plugins-sync: invalid or empty manifest: $manifest" >&2
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
done < <(jq -r '.plugins | to_entries[] | [.key, .value.path, (.value.enabled | tostring)] | @tsv' "$manifest")

# Remove plugins that were present in the pre-update snapshot only after every
# declared plugin has linked successfully. The Nix catalog owns the complete
# registry, so plugins installed or linked manually are intentionally removed.
for id in $installed; do
    if ! jq -e --arg id "$id" '.plugins | has($id)' "$manifest" >/dev/null; then
        herdr plugin unlink "$id"
    fi
done
