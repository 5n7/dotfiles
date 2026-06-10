#!/bin/sh
# Claude / Anthropic service status indicator for ccstatusline (Tokyo Night).
# Reads the public Statuspage JSON (https://status.claude.com/api/v2/status.json).
#
# Non-blocking by design: it prints the cached status immediately and, when the
# cache is older than TTL, kicks off a detached background refresh for next time.
# So the statusline render never waits on the network.
#
#   none(operational) -> green dot     minor -> yellow     major -> orange
#   critical          -> red "outage"  unknown/unreachable -> muted dot

. "${0%/*}/lib.sh"

CACHE_DIR="$HOME/.cache/ccstatusline"
CACHE="$CACHE_DIR/claude-status"
LOCK="$CACHE.lock"
TTL=60
URL="https://status.claude.com/api/v2/status.json"

mkdir -p "$CACHE_DIR" 2>/dev/null
now=$(date +%s)

indicator="unknown"
age=999999
if [ -f "$CACHE" ]; then
    read -r ts indicator <"$CACHE" 2>/dev/null
    [ -z "$indicator" ] && indicator="unknown"
    case "$ts" in '' | *[!0-9]*) ts=0 ;; esac
    age=$((now - ts))
fi

# Clean a stale lock (>2 min) left by a killed refresh.
if [ -d "$LOCK" ] && [ -n "$(find "$LOCK" -maxdepth 0 -mmin +2 2>/dev/null)" ]; then
    rmdir "$LOCK" 2>/dev/null
fi

# Refresh in the background when stale (single-flight via mkdir lock).
if [ "$age" -ge "$TTL" ] && mkdir "$LOCK" 2>/dev/null; then
    (
        new=$(curl -fsS --max-time 5 "$URL" 2>/dev/null | jq -r '.status.indicator // empty' 2>/dev/null)
        [ -n "$new" ] && printf '%s %s\n' "$(date +%s)" "$new" >"$CACHE.tmp" && mv "$CACHE.tmp" "$CACHE"
        rmdir "$LOCK" 2>/dev/null
    ) >/dev/null 2>&1 &
fi

case "$indicator" in
none) printf '%b' "${green}●${reset}" ;;
minor) printf '%b' "${yellow}● minor${reset}" ;;
major) printf '%b' "${orange}● major${reset}" ;;
critical) printf '%b' "${red}● outage${reset}" ;;
*) printf '%b' "${muted}●${reset}" ;;
esac
