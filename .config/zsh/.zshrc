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

source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/history.zsh"
source "$ZDOTDIR/homebrew.zsh"
source "$ZDOTDIR/hooks.zsh"
source "$ZDOTDIR/keymaps.zsh"

eval "$(mise activate zsh)"
eval "$(sheldon source)"
eval "$(starship init zsh)"

source <(gwq completion zsh)

zsh-defer eval "$(direnv hook zsh)"
