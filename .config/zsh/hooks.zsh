chpwd-rename-wezterm-window() {
    [[ -z "$WEZTERM_PANE" ]] && return

    local title="${PWD##*/}"
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        title="$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")"
    fi
    wezterm cli set-tab-title "$title"
}

autoload -Uz add-zsh-hook
[[ -n "$WEZTERM_PANE" ]] && add-zsh-hook chpwd chpwd-rename-wezterm-window
