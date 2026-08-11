# Credential env vars backed by a cache file instead of a subprocess.
#
# These were `export VAR=$(...)` in ~/.zshenv.local. .zshenv runs for every zsh,
# non-interactive ones included, so each shell booted wrangler (Node, ~1s) and
# forked gh (~50ms). Here the value is read from a 0600 cache with a builtin and
# refreshed out of band once past the TTL. That also fixes the eager version's
# bug: the Cloudflare value is a short-lived OAuth access token, so a long-lived
# shell held an expired one until restart.
#
# The credentials are already plaintext under ~/.config/gh and ~/.config/.wrangler,
# so the cache is not a new class of exposure. Requires extended_glob (options.zsh).

_env_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/env"
# Minutes. Kept well under the Cloudflare OAuth access token lifetime (~1h).
_env_cache_ttl=30
typeset -gA _env_cache_cmds

# Read the cached value into the environment. Builtin only, no fork.
_env_cache_load() {
    local file="$_env_cache_dir/$1"
    [[ -s "$file" ]] && export "$1=$(<"$file")"
}

# Run the provider and replace the cache atomically. Slow; only on a cache miss.
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

# Force a synchronous refresh. Run after `gh auth switch`, `wrangler login`, etc.
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

[[ -d "$_env_cache_dir" ]] || { mkdir -p "$_env_cache_dir" && chmod 700 "$_env_cache_dir"; }

env-cache CLOUDFLARE_TOKEN 'wrangler auth token --json | jq -r .token'
env-cache GITHUB_TOKEN 'gh auth token'

autoload -Uz add-zsh-hook
add-zsh-hook precmd _env_cache_precmd
