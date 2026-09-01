# Homebrew casks grouped by host: common casks plus the active profile's own group.
{ host }:
let
  casks = {
    common = [
      "1password"
      "1password-cli"
      "chatgpt"
      "claude"
      "codex-app"
      "cursor"
      "dockdoor"
      "gcloud-cli"
      "ghostty"
      "google-chrome"
      "jordanbaird-ice@beta"
      "karabiner-elements"
      "keyboardcleantool"
      "linear"
      "meetingbar"
      "ngrok"
      "notion"
      "raycast"
      "scroll-reverser"
      "slack"
      "spotify"
      "tailscale-app"
      "thebrowsercompany-dia"
    ];
    personal = [
      "adobe-creative-cloud"
      "brave-browser"
      "cursor-cli"
      "elecom-mouse-util"
      "grok-bot"
      "grok-build"
      "hermes-desktop"
      "raspberry-pi-imager"
      "vlc"
      "voiceink"
    ];
    work = [
      "zoom"
    ];
  };
in
casks.common ++ casks.${host.profile}
