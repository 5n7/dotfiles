# shellcheck shell=bash
#
# Merge a declared JSON object into ~/.pi/agent/settings.json, leaving every key
# the object does not mention untouched. pi.nix runs this on activation with the
# subset Nix declares; run it by hand with the same shape:
#
#   pi-settings-merge '{"theme":"dark","packages":["npm:pi-lens"]}'
#
# writeShellApplication supplies the shebang and the `set -o` flags, so this file
# carries neither. The `shell` directive above is what lets shellcheck read it on
# its own — without a shebang it would otherwise bail out with SC2148.

if [ $# -ne 1 ]; then
    echo "usage: pi-settings-merge <declared-json>" >&2
    exit 2
fi

declared=$1
file="$HOME/.pi/agent/settings.json"

mkdir -p "$(dirname "$file")"

# Create the file before merging so it always ends up with the umask's mode. Left
# to `cp` below, a file that did not exist yet would inherit 0600 from mktemp,
# while pi's own default is 0644. Slurping turns the empty file into `{}`, so no
# separate missing-file branch is needed.
[ -e "$file" ] || : >"$file"

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# `. * $declared` is a recursive merge with the right operand winning, so every
# undeclared key survives and arrays are replaced whole rather than concatenated
# — which is what `packages` wants.
jq -s --argjson declared "$declared" '(.[0] // {}) * $declared' "$file" >"$tmp"

# The merged JSON is copied over the file rather than moved onto it: `cp` keeps
# the mode of the destination, while the 0600 `mktemp` file moved into place
# would leave it 0600.
cp "$tmp" "$file"
