# Homebrew casks grouped by host: common casks plus the active profile's own group.
{ host }:
let
  casks = {
    common = [
      "claude"
      "dockdoor"
      "gcloud-cli"
      "ghostty"
      "google-chrome"
      "herdr-app"
      "karabiner-elements"
      "meetingbar"
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
      "1password"
      "1password-cli"
      "adobe-creative-cloud"
      "block-buzz"
      "brave-browser"
      "cursor-cli"
      "elecom-mouse-util"
      "grok-bot"
      "grok-build"
      "keyboardcleantool"
      "ngrok"
      "notion"
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
