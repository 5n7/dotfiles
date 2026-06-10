# zsh utility functions. Loaded from programs.zsh.initContent.
gmi() { go mod init "$(pwd | sed -e 's/.*github.com/github.com/g')"; }
mkcd() { mkdir -p "$1" && cd "$1"; }
targz() { tar -cvzf "$1.tar.gz" "$1"; }
untargz() { tar -xvzf "$1.tar.gz"; }

# Check out a PR by number as a git worktree (via git-wt).
ghpw() {
    local pr="$1"
    if [[ -z "$pr" ]]; then
        echo "usage: ghpw <pr-number>" >&2
        return 1
    fi
    local branch
    branch=$(gh pr view "$pr" --json headRefName --jq .headRefName) || return
    if ! git show-ref --verify --quiet "refs/heads/$branch"; then
        git fetch origin "refs/pull/${pr}/head:${branch}" || return
    fi
    git wt "$branch"
}
