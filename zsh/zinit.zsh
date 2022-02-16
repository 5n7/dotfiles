ZINIT_PATH="$HOME/.local/share/zinit/zinit.git/zinit.zsh"

if [[ ! -f "$ZINIT_PATH" ]]; then
  NO_EDIT=1 NO_TUTORIAL=1 sh -c "$(curl -L https://git.io/zinit-install)"
fi

source "$ZINIT_PATH"

zinit ice blockf depth"1" lucid wait
zinit light-mode for \
  agkozak/zsh-z \
  Aloxaf/fzf-tab \
  mollifier/cd-gitroot \
  NullSense/fuzzy-sys \
  reegnz/jq-zsh-plugin \
  wfxr/forgit \
  zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions
