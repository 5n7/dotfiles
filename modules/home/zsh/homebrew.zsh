# gcloud's bin dir is in home.sessionPath (default.nix), so skip the blocking
# path.zsh.inc and only defer the completion init.
if [[ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ]]; then
    zsh-defer source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
fi
