# Cached compinit. Refresh dump daily; otherwise skip security audit + dump.
autoload -Uz compinit
local _zdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
[[ -d "${_zdump:h}" ]] || mkdir -p "${_zdump:h}"
if [[ -f "$_zdump" && -z "$_zdump"(#qN.mh+24) ]]; then
    compinit -C -d "$_zdump"
else
    compinit -d "$_zdump"
fi
if [[ ! -f "$_zdump.zwc" || "$_zdump" -nt "$_zdump.zwc" ]]; then
    zcompile "$_zdump" &!
fi
unset _zdump
