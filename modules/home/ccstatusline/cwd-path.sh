#!/bin/sh
# Working-directory widget for ccstatusline (Tokyo Night palette).
# Inside a git repo:  "owner/repo[/subdir]"  (owner/repo from the origin remote;
#   falls back to the repo directory name when there is no remote).
#   owner = orange, repo = cyan, subpath = muted blue-gray.
# Outside a repo:     the path with $HOME collapsed to "~", in muted foreground.
# ASCII-only output, so colors are emitted via printf %b (\033 escapes).

. "${0%/*}/lib.sh"

dir=$(jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)
[ -z "$dir" ] && dir=$PWD
cd "$dir" 2>/dev/null || exit 0

# One git call for both values; line 1 is "true", line 2 the prefix (may be absent at repo root).
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
