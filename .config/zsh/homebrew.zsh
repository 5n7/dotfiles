fpath+="/opt/homebrew/share/zsh/site-functions"

autoload -Uz compinit

if [[ -f "${ZDOTDIR}/.zcompdump" && $(date +'%j') != $(stat -f '%Sm' -t '%j' "${ZDOTDIR}/.zcompdump") ]]; then
    compinit
else
    compinit -C
fi

source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
