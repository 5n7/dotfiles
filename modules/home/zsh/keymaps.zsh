# zsh keymaps and fzf widgets. Loaded from programs.zsh.initContent.
autoload -Uz edit-command-line

bindkey -v
bindkey -M viins "jj" vi-cmd-mode

zle -N edit-command-line
bindkey "^e" edit-command-line

# Shared fzf preview for directory pickers: render the README if present,
# otherwise a tree listing.
_fzf_dir_preview='[[ -f {}/README.md ]] && glow --style dark {}/README.md || eza -Ta --icons=always --git-ignore {}'

fzf::cd() {
    local dir=$(fd --hidden --type directory | fzf --preview "$_fzf_dir_preview")
    [[ -n "$dir" ]] || return
    BUFFER="cd $dir"
    zle accept-line
}
zle -N fzf::cd
bindkey "^T" fzf::cd

fzf::cd-ghq() {
    local dir=$(ghq list -p | fzf --preview "$_fzf_dir_preview")
    [[ -n "$dir" ]] || return
    BUFFER="cd $dir"
    zle accept-line
}
zle -N fzf::cd-ghq
bindkey "^G" fzf::cd-ghq

fzf::cd-wt() {
    local dir=$(git wt | fzf --header-lines=1 --preview 'p={1}; [[ "$p" == "*" ]] && p={2}; git -C "$p" log --color=always --date=relative --graph --pretty=format:"%C(auto)%h %s%d %C(green)(%cr) %C(bold blue)<%an>"' | awk '{if ($1 == "*") print $2; else print $1}')
    [[ -n "$dir" ]] || return
    BUFFER="cd $dir"
    zle accept-line
}
zle -N fzf::cd-wt
bindkey "^W" fzf::cd-wt

fzf::ghpw() {
    local pr=$(gh pr list --limit 100 \
        --json number,title,headRefName,author \
        --template '{{range .}}{{printf "%v\t%v\t%v\t%v\n" .number .title .headRefName .author.login}}{{end}}' |
        fzf --preview 'gh pr view {1}' | awk '{print $1}')
    [[ -n "$pr" ]] || return
    BUFFER="ghpw $pr"
    zle accept-line
}
zle -N fzf::ghpw
bindkey "^P" fzf::ghpw

fzf::git-switch-branch() {
    local branch=$(git branch --format='%(refname:short)' | fzf --preview "git log --color=always --date=relative --graph --pretty=format:'%C(auto)%h %s%d %C(green)(%cr) %C(bold blue)<%an>' {}")
    [[ -n "$branch" ]] || return
    BUFFER="git switch $branch"
    zle accept-line
}
zle -N fzf::git-switch-branch
bindkey "^B" fzf::git-switch-branch

fzf::history() {
    BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER")
    CURSOR=$#BUFFER
}
zle -N fzf::history
bindkey "^H" fzf::history

fzf::kill() {
    local pid=$(ps -fu "$UID" | sed 1d | fzf -m | awk '{print $2}')
    [[ -n "$pid" ]] && echo $pid | xargs kill -${1:-9}
}
zle -N fzf::kill
bindkey "^K" fzf::kill

fzf::open() {
    local file=$(fd --hidden --type file | fzf --preview "bat --color always --style header {}")
    [[ -n "$file" ]] || return
    $EDITOR $file
}
zle -N fzf::open
bindkey "^O" fzf::open
