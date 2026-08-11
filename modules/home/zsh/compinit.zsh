# Cached compinit. Always load with -C: without it compinit runs a security
# audit that globs every fpath directory (~110ms). A dump older than a day is
# rebuilt, audit included, in a background shell -- this shell keeps the slightly
# stale dump and the next one picks up the fresh one. Either way the dump is
# zcompiled whenever its .zwc is missing or older than the dump.
autoload -Uz compinit
_zdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
[[ -d "${_zdump:h}" ]] || mkdir -p "${_zdump:h}"
if [[ -f "$_zdump" ]]; then
    compinit -C -d "$_zdump"
    if [[ -n "$_zdump"(#qN.mh+24) ]]; then
        zsh -c "autoload -Uz compinit; compinit -d ${(q)_zdump}; zcompile ${(q)_zdump}" &|
    elif [[ ! -f "$_zdump.zwc" || "$_zdump" -nt "$_zdump.zwc" ]]; then
        zcompile "$_zdump" &|
    fi
else
    compinit -d "$_zdump"
    zcompile "$_zdump" &|
fi
unset _zdump
