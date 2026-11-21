#!/bin/sh
# Inside a git repo, prints "owner/repo[/subdir]" with owner/repo taken from
# the origin remote, or just the repo directory name without one. Elsewhere,
# prints the path with $HOME collapsed to "~".

. "${0%/*}/lib.sh"

dir=$(jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)
[ -z "$dir" ] && dir=$PWD
cd "$dir" 2>/dev/null || exit 0

# One git call for both values: line 1 is "true", line 2 the prefix, absent at the repo root.
if info=$(git rev-parse --is-inside-work-tree --show-prefix 2>/dev/null); then
    { read -r _ && read -r prefix; } <<EOF
$info
EOF
    prefix=${prefix%/}

    url=$(git remote get-url origin 2>/dev/null)
    if [ -n "$url" ]; then
        url=${url%.git}
        url=${url%/}
        repo=${url##*/}
        rest=${url%/*}
        owner=${rest##*[:/]} # handles both https://host/owner and scp-style git@host:owner
    else
        repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
        owner=''
    fi

    if [ -n "$owner" ]; then
        out="${orange}${owner}/${reset}${cyan}${repo}${reset}"
    else
        out="${cyan}${repo}${reset}"
    fi
    [ -n "$prefix" ] && out="${out}${muted}/${prefix}${reset}"
    printf '%b' "$out"
else
    case "$dir" in
    "$HOME") disp='~' ;;
    "$HOME"/*) disp="~${dir#"$HOME"}" ;;
    *) disp="$dir" ;;
    esac
    printf '%b' "${fg_dark}${disp}${reset}"
fi
