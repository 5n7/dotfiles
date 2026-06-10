# Tool init deferred for startup speed: Home Manager's native zsh integration is
# disabled for direnv/zoxide/mise (see shell.nix and mise.nix) and `git wt
# --init` has no Home Manager module. Their init output is pre-rendered to cache
# files by home.activation.precomputeShellInit; we zsh-defer source those cached
# files here instead of spawning a subprocess + eval on every shell. Falls back
# to live `eval "$(...)"` when a cache file is missing (e.g. a fresh machine
# before its first rebuild). Loaded from programs.zsh.initContent.
if command -v zsh-defer >/dev/null 2>&1; then
    _cache="${XDG_CACHE_HOME:-$HOME/.cache}"
    _defer_cached() {
        if [[ -f "$_cache/$1" ]]; then
            zsh-defer source "$_cache/$1"
        else
            zsh-defer -c "$2"
        fi
    }
    _defer_cached direnv/hook.zsh 'eval "$(direnv hook zsh)"'
    _defer_cached zoxide/init.zsh 'eval "$(zoxide init zsh)"'
    _defer_cached git-wt/init.zsh 'eval "$(git wt --init zsh)"'
    _defer_cached mise/activate.zsh 'eval "$(mise activate zsh)"'
    unfunction _defer_cached
    unset _cache
fi
