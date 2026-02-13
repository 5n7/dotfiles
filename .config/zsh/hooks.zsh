chpwd-ls() {
    eza -la --color=always --icons=always --git-repos | head -24
}

chpwd-rename-wezterm-window() {
    [[ -z "$WEZTERM_PANE" ]] && return

    # Set the title to the current directory name
    local title="${PWD##*/}"

    # If the current directory is a git repository, set the title to the repository name
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local dir="$(git rev-parse --show-toplevel 2>/dev/null)"
        local repo_name="${dir##*/}"
        local parent_path="${dir%/*}"
        local parent_dir="${parent_path##*/}"
        title="${parent_dir}/${repo_name}"
    fi

    wezterm cli set-tab-title "$title"
}

autoload -Uz add-zsh-hook

add-zsh-hook chpwd chpwd-ls
[[ -n "$WEZTERM_PANE" ]] && add-zsh-hook chpwd chpwd-rename-wezterm-window
