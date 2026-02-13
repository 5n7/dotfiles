#!/usr/bin/env zsh

source "$(dirname $0)/lib/command.sh"
source "$(dirname $0)/lib/print.sh"
source "$(dirname $0)/lib/symlink.sh"

print_info "Setting up dotfiles..."

source "$(dirname $0)/.zshenv"
mkdir -p "${XDG_CONFIG_HOME}"
mkdir -p "${XDG_STATE_HOME}/zsh"

create_symlink "${DOTFILES_DIR}/.Brewfile" "${HOME}/.Brewfile"
create_symlink "${DOTFILES_DIR}/.config/borders" "${XDG_CONFIG_HOME}/borders"
create_symlink "${DOTFILES_DIR}/.config/git" "${XDG_CONFIG_HOME}/git"
create_symlink "${DOTFILES_DIR}/.config/gitui" "${XDG_CONFIG_HOME}/gitui"
create_symlink "${DOTFILES_DIR}/.config/mise" "${XDG_CONFIG_HOME}/mise"
create_symlink "${DOTFILES_DIR}/.config/nvim" "${XDG_CONFIG_HOME}/nvim"
create_symlink "${DOTFILES_DIR}/.config/sheldon" "${XDG_CONFIG_HOME}/sheldon"
create_symlink "${DOTFILES_DIR}/.config/starship.toml" "${XDG_CONFIG_HOME}/starship.toml"
create_symlink "${DOTFILES_DIR}/.config/tmux" "${XDG_CONFIG_HOME}/tmux"
create_symlink "${DOTFILES_DIR}/.config/wezterm" "${XDG_CONFIG_HOME}/wezterm"
create_symlink "${DOTFILES_DIR}/.config/zsh" "${XDG_CONFIG_HOME}/zsh"
create_symlink "${DOTFILES_DIR}/.gitconfig" "${HOME}/.gitconfig"
create_symlink "${DOTFILES_DIR}/.zshenv" "${HOME}/.zshenv"

if is_command_available mise; then
    print_info "Installing tools with mise..."
    mise install
fi

print_success "Setup complete!"
