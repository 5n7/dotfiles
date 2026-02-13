# global

alias -g G="| rg"
alias -g H="| head"
alias -g L="| less"
alias -g T="| tail"

# directory movement

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

alias dl="cd $HOME/Downloads"
alias sb="cd $HOME/sandbox"

# file operations

alias cp="cp -ir"
alias mkcd="mkdir -p $1 && cd $1"
alias mkdir="mkdir -p"
alias mv="mv -i"
alias rm="gomi"

alias l="eza -l --icons=always --git-repos"
alias la="eza -la --icons=always --git-repos"
alias tree="eza -Ta --icons=always --git-ignore"

alias targz="tar -cvzf $1.tar.gz $1"
alias untargz="tar -xvzf $1.tar.gz"

# development

alias c="cursor ."
alias cc="claude --dangerously-skip-permissions"
alias cch="claude --dangerously-skip-permissions --model haiku"
alias ccs="claude --dangerously-skip-permissions --model sonnet"
alias cx="codex --dangerously-bypass-approvals-and-sandbox"
alias v="nvim"

alias d="docker"
alias dc="docker compose"
alias dim="docker images"
alias dps="docker ps"
alias dpsa="docker ps -a"

alias g="git"
alias ga="git add"
alias gb="git branch"
alias gc="claude --dangerously-skip-permissions --model haiku -p '/git-commit' > /dev/null 2>&1 && git log -1"
alias gco="git checkout"
alias gcp="git cherry-pick"
alias gd="git diff"
alias gf="git fetch"
alias gl="git log"
alias gm="git merge"
alias gp="git push"
alias gpl="git pull"
alias gplo="git pull origin"
alias gpo="git push origin"
alias gr="git rebase"
alias gs="git status"
alias gst="git stash"
alias gsw="git switch"

alias gu="gitui"

alias gmt="go mod tidy"
alias gmv="go mod vendor"
alias gmi="go mod init $(pwd | sed -e 's/.*github.com/github.com/g')"

alias k="kubectl"
alias kubectx="kubectl-ctx"
alias tf="terraform"
