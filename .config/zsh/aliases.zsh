alias cp="cp -ir"
alias mkdir="mkdir -p"
alias mkcd="mkdir -p $1 && cd $1"
alias mv="mv -i"
alias rm="gomi"
alias targz="tar -cvzf $1.tar.gz $1"
alias untargz="tar -xvzf $1.tar.gz"

alias gmi="go mod init $(pwd | sed -e 's/.*github.com/github.com/g')"
