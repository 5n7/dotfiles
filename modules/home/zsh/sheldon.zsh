# Pre-rendered by home.activation.precomputeShellInit; falls back to live
# `sheldon source`. Must run before anything that calls zsh-defer, which
# sheldon loads.
if [[ -f "${XDG_CACHE_HOME:-$HOME/.cache}/sheldon/source.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/sheldon/source.zsh"
else
    eval "$(sheldon source)"
fi
