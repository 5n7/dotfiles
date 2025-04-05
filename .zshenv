# basic
export EDITOR="nvim"

# XDG
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Homebrew
export HOMEBREW_NO_INSTALL_FROM_API=1
export PATH="/opt/homebrew/bin:$PATH"

# dotfiles
export DOTFILES_DIR="$HOME/src/github.com/5n7/dotfiles"

# ghq
export GHQ_ROOT="$HOME/src"

# Go
export GOPATH="$XDG_DATA_HOME/go"
export PATH="$GOPATH/bin:$PATH"
export GOPRIVATE="github.com/5n7,github.com/mansion-friends"

# Zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# local
[[ -f "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"
