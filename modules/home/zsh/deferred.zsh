# Deferred tool init. Home Manager's zsh integrations for direnv, zoxide and
# mise are off (shell.nix, mise.nix), and git-wt has none. Cached tools source
# what home.activation.precomputeShellInit rendered, or fall back to a live
# `eval` when the cache is missing.
_cache="${XDG_CACHE_HOME:-$HOME/.cache}"
_defer_cached() {
    if [[ -f "$_cache/$1" ]]; then
        zsh-defer source "$_cache/$1"
    else
        zsh-defer -c "$2"
    fi
}
_defer_cached direnv/hook.zsh 'eval "$(direnv hook zsh)"'
_defer_cached git-wt/init.zsh 'eval "$(git wt --init zsh)"'
# Not cached: `mise activate` bakes the caller's PATH into its output.
zsh-defer -c 'eval "$(mise activate zsh)"'
_defer_cached zoxide/init.zsh 'eval "$(zoxide init zsh)"'

# direnv and zoxide both hook chpwd, which is where `cd` pays. Their init is
# generated, so patch the hooks after loading rather than fork the upstream
# scripts. zsh-defer runs in FIFO order, so this runs after the sources it
# patches. Saves ~19ms per `cd` (49ms -> 30ms for chpwd+precmd in a 90k-file
# monorepo).
_trim_cd_hooks() {
    # `zoxide add` forks twice per cd, once for $(pwd) and once for the
    # binary, and nothing reads its result. $PWD is already `pwd -L`, so drop
    # the first fork and background the second. `&|` disowns immediately,
    # which keeps ${#jobstates} accurate for oh-my-posh's --job-count.
    if (($+functions[__zoxide_hook])); then
        __zoxide_hook() { { \command zoxide add -- "$PWD"; } &| }
    fi

    # direnv hooks chpwd and precmd, so a plain `cd` runs `direnv export`
    # twice. Skip the precmd after a simple command that changed directory,
    # but not after a list: in `cd x && direnv allow` the allow DB or watches
    # change between the two hooks. The wrappers go first so export runs
    # before mise and the prompt.
    if (($+functions[_direnv_hook])); then
        functions[_direnv_export]=$functions[_direnv_hook]
        typeset -g _direnv_exported_on_chpwd=0
        typeset -g _direnv_cmd=
        _direnv_hook_chpwd() {
            _direnv_export
            _direnv_exported_on_chpwd=1
        }
        _direnv_hook_preexec() {
            _direnv_cmd=$1
        }
        _direnv_hook_precmd() {
            if ((_direnv_exported_on_chpwd)); then
                _direnv_exported_on_chpwd=0
                if [[ -n $_direnv_cmd && $_direnv_cmd != *'&&'* && $_direnv_cmd != *';'* && $_direnv_cmd != *'||'* && $_direnv_cmd != *'|'* && $_direnv_cmd != *$'\n'* ]]; then
                    return
                fi
            fi
            _direnv_export
        }
        chpwd_functions=(_direnv_hook_chpwd "${(@)chpwd_functions:#_direnv_hook}")
        precmd_functions=(_direnv_hook_precmd "${(@)precmd_functions:#_direnv_hook}")
        preexec_functions=(_direnv_hook_preexec $preexec_functions)
    fi

    unfunction _trim_cd_hooks
}
zsh-defer -c _trim_cd_hooks

unfunction _defer_cached
unset _cache
