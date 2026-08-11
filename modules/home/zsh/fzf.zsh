# Pre-rendered fzf shell integration; HM's emits `source <(fzf --zsh)`, forking
# fzf every shell. Falls back to live `fzf --zsh` if the cache is missing.
# Must precede keymaps.zsh, whose ^T binding overrides fzf's.
if [[ -f "${XDG_CACHE_HOME:-$HOME/.cache}/fzf/init.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/fzf/init.zsh"
else
    source <(fzf --zsh)
fi
