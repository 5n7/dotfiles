# shellcheck shell=bash
#
# Mods are copied in as real files rather than linked: the app refuses to import
# a module whose real path is outside the mod's folder, and it writes
# jsconfig.json and gpui-kit.d.ts beside each mod. A hidden marker, which the
# app ignores, marks the folders this script owns, so mods made by hand or
# shipped with the app are left alone. An unmarked folder counts as someone
# else's mod only if it holds main.js, which every mod needs; otherwise, such as
# a folder holding only the app's files or a .DS_Store, it is taken over.
#
# writeShellApplication supplies the shebang and the `set -o` flags.

if [ $# -ne 2 ]; then
    echo "usage: herdr-app-mods-sync <mods dir> <manifest.json>" >&2
    exit 2
fi
mods=$1
manifest=$2
marker=.nix-managed

# The app reloads a mod whenever one of its files is saved. rsync writes each
# changed file beside its target and renames it into place, so a reload never
# sees a half-written file. It compares checksums because every store file has
# the same timestamp. The app's own files are excluded, which also keeps
# --delete away from them.
while IFS=$'\t' read -r name source; do
    dest=$mods/$name
    if [ ! -e "$dest/$marker" ] && [ -e "$dest/main.js" ]; then
        echo "herdr-app-mods-sync: $dest is a mod Nix did not install; skipping $name" >&2
        continue
    fi
    # Marked before copying, so a copy that fails partway is retried next time.
    mkdir -p "$dest"
    touch "$dest/$marker"
    rsync --recursive --copy-links --perms --chmod=u+w --checksum --delete \
        --exclude=/jsconfig.json --exclude='/*.d.ts' --exclude="/$marker" \
        "$source/" "$dest/"
done < <(jq -r 'to_entries[] | [.key, .value] | @tsv' "$manifest")

for dest in "$mods"/*/; do
    dest=${dest%/}
    name=${dest##*/}
    if [ -e "$dest/$marker" ] && ! jq -e --arg name "$name" 'has($name)' "$manifest" >/dev/null; then
        rm -rf "$dest"
    fi
done
