# Homebrew casks grouped by host: common casks plus the active profile's own group.
{ host }:
let
  casks = {
    common = [
      "1password"
      "1password-cli"
      "claude"
      "dockdoor"
      "gcloud-cli"
      "ghostty"
      "google-chrome"
      "karabiner-elements"
      "keyboardcleantool"
      "meetingbar"
      "notion"
      {
        name = "BarutSRB/tap/omniwm";
        trusted = true;
      }
      "scroll-reverser"
      "slack"
      "spotify"
      "tailscale-app"
      "vicinae"
    ];
    personal = [
      "adobe-creative-cloud"
      "block-buzz"
      "brave-browser"
      "cursor-cli"
      "elecom-mouse-util"
      "grok-bot"
      "grok-build"
      "ngrok"
      "raspberry-pi-imager"
      "vlc"
      "voiceink"
    ];
    work = [
      "caffeine"
      "linear"
      "zoom"
    ];
  };
in
casks.common ++ casks.${host.profile}
