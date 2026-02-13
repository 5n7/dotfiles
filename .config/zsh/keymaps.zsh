autoload -Uz edit-command-line

bindkey -v
bindkey -M viins "jj" vi-cmd-mode

zle -N edit-command-line
bindkey "^e" edit-command-line

fzf::cd() {
    local dir=$(fd --hidden --type directory | fzf --preview "tree {}")
    if [[ -n "$dir" ]]; then
        BUFFER="cd $dir"
        zle accept-line
    fi
}
zle -N fzf::cd
bindkey "^T" fzf::cd

fzf::cd-ghq() {
    local dir=$(ghq list -p | fzf --preview '[[ -f {}/README.md ]] && glow --style dark {}/README.md || eza -Ta --icons=always --git-ignore {}')
    if [[ -n "$dir" ]]; then
        BUFFER="cd $dir"
        zle accept-line
    fi
}
zle -N fzf::cd-ghq
bindkey "^G" fzf::cd-ghq

fzf::gcloud-config() {
    local config=$(gcloud config configurations list --format='table(is_active.yesno(yes="[x]",no="[_]"),name,properties.core.account,properties.core.project.yesno(no="(unset)"))' | fzf --header-lines=1 | awk '{print $2}')
    [[ -n "$config" ]] && gcloud config configurations activate "$config"
}

fzf::git-checkout-branch() {
    local branch=$(git branch --format='%(refname:short)' | fzf --preview "git log --color=always --date=relative --graph --pretty=format:'%C(auto)%h %s%d %C(green)(%cr) %C(bold blue)<%an>' {}")
    if [[ -n "$branch" ]]; then
        BUFFER="git switch $branch"
        zle accept-line
    fi
}
zle -N fzf::git-checkout-branch
bindkey "^B" fzf::git-checkout-branch

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
    [[ -n "$file" ]] && $EDITOR $file
}
zle -N fzf::open
bindkey "^O" fzf::open
