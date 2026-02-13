setopt auto_list
setopt auto_menu
setopt auto_param_keys
setopt auto_pushd
setopt auto_remove_slash
setopt auto_resume
setopt correct
setopt extended_glob
setopt ignore_eof
setopt interactive_comments
setopt magic_equal_subst
setopt mark_dirs
setopt no_beep
setopt no_flow_control
setopt no_list_beep
setopt nonomatch
setopt numeric_glob_sort
setopt pushd_ignore_dups

# sheldon (cached)
_sheldon_cache="$ZDOTDIR/.sheldon.cache.zsh"
_sheldon_toml="$XDG_CONFIG_HOME/sheldon/plugins.toml"
_sheldon_lock="$XDG_DATA_HOME/sheldon/plugins.lock"
if [[ ! -f "$_sheldon_cache" || "$_sheldon_toml" -nt "$_sheldon_cache" || "$_sheldon_lock" -nt "$_sheldon_cache" ]]; then
    sheldon source > "$_sheldon_cache"
fi
source "$_sheldon_cache"
unset _sheldon_cache _sheldon_toml _sheldon_lock

source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/history.zsh"
source "$ZDOTDIR/homebrew.zsh"
source "$ZDOTDIR/hooks.zsh"
source "$ZDOTDIR/keymaps.zsh"

# starship (cached)
_starship_cache="$ZDOTDIR/.starship.cache.zsh"
if [[ ! -f "$_starship_cache" ]]; then
    starship init zsh > "$_starship_cache"
fi
source "$_starship_cache"
unset _starship_cache

zsh-defer -c 'eval "$(direnv hook zsh)"'
zsh-defer -c 'eval "$(mise activate zsh)"'
