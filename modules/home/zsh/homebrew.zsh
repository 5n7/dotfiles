# gcloud SDK init. Loaded from programs.zsh.initContent. The SDK bin dir is added
# to PATH via home.sessionPath (see default.nix), so we skip the blocking
# path.zsh.inc source and only defer the completion init.
if command -v zsh-defer >/dev/null 2>&1 && [[ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ]]; then
    zsh-defer source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
fi
