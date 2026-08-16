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
    _defer_cached git-wt/init.zsh 'eval "$(git wt --init zsh)"'
    _defer_cached mise/activate.zsh 'eval "$(mise activate zsh)"'
    _defer_cached zoxide/init.zsh 'eval "$(zoxide init zsh)"'

    # direnv and zoxide both hook chpwd, which is where the cost of `cd` shows
    # up. Their init output is generated, so trim the hooks after the fact rather
    # than forking the upstream scripts. Queued with zsh-defer below, which keeps
    # FIFO order, so it runs once the sources it patches have loaded. Together
    # this is ~19ms off every `cd` (49ms -> 30ms for chpwd+precmd in a 90k-file
    # monorepo).
    _trim_cd_hooks() {
        # `zoxide add` forks twice per cd -- once for the $(pwd) substitution,
        # once for the binary -- and nothing reads its result. $PWD is already
        # `pwd -L`, so drop that fork and background the rest. `&|` disowns
        # immediately, which keeps ${#jobstates} accurate; oh-my-posh reports it
        # as --job-count.
        if (($+functions[__zoxide_hook])); then
            __zoxide_hook() { { \command zoxide add -- "$PWD"; } &| }
        fi

        # direnv hooks both chpwd and precmd; drop the immediate follow-up
        # precmd after a simple directory change (the second `direnv export`
        # is the cost). Do not skip after a list — `cd x && direnv allow`
        # changes the allow DB / watches between the two hooks. Wrappers stay
        # first so export happens before mise and the prompt.
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
fi
