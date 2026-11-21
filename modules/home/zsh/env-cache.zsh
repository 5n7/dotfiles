# Credential env vars read from a cache file instead of a subprocess. As
# `export VAR=$(...)` in ~/.zshenv.local, they made every zsh, non-interactive
# ones included, boot wrangler (Node, ~1s). Here a builtin reads a 0600 cache
# that is refreshed in the background past the TTL. The Cloudflare value is a
# short-lived OAuth access token, so the refresh also keeps long-lived shells
# from holding an expired one.
#
# wrangler already stores the credential in plaintext under ~/.config/.wrangler,
# so the cache adds no new exposure. Requires extended_glob (options.zsh).

_env_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/env"
# Minutes. Kept well under the Cloudflare OAuth access token lifetime (~1h).
_env_cache_ttl=30
typeset -gA _env_cache_cmds

# gh prefers GITHUB_TOKEN over its stored login, so drop any inherited one,
# including a token exported by this cache before it stopped caching gh.
unset GITHUB_TOKEN

# Builtin only, no fork.
_env_cache_load() {
    local file="$_env_cache_dir/$1"
    [[ -s "$file" ]] && export "$1=$(<"$file")"
}

# Slow: runs on a miss, in the background when stale, and on refresh.
_env_cache_fetch() {
    local file="$_env_cache_dir/$1" tmp="$_env_cache_dir/$1.$$"
    if (
        umask 077
        eval "$_env_cache_cmds[$1]" >"$tmp" 2>/dev/null
    ) && [[ -s "$tmp" ]]; then
        mv -f "$tmp" "$file"
    else
        rm -f "$tmp"
        return 1
    fi
}

# env-cache <VAR> <provider command>
env-cache() {
    _env_cache_cmds[$1]="$2"
    [[ -f "$_env_cache_dir/$1" ]] || _env_cache_fetch "$1"
    _env_cache_load "$1"
}

# Force a synchronous refresh, e.g. after `wrangler login`.
env-cache-refresh() {
    local var
    for var in ${(k)_env_cache_cmds}; do
        _env_cache_fetch "$var" && _env_cache_load "$var"
    done
}

# The freshness check is a glob-qualifier stat, so the fresh case costs no fork.
_env_cache_precmd() {
    local var file
    for var in ${(k)_env_cache_cmds}; do
        file="$_env_cache_dir/$var"
        if [[ -z "$file"(#qN.mm-$_env_cache_ttl) ]]; then
            # Stale. Bump the mtime first so concurrent shells do not all spawn a
            # provider; this shell keeps the old value until the next prompt.
            command touch "$file" 2>/dev/null
            (_env_cache_fetch "$var") &|
        fi
        _env_cache_load "$var"
    done
}

[[ -d "$_env_cache_dir" ]] || mkdir -p -m 700 "$_env_cache_dir"

env-cache CLOUDFLARE_TOKEN 'wrangler auth token --json | jq -r .token'

autoload -Uz add-zsh-hook
add-zsh-hook precmd _env_cache_precmd
