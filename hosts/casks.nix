# Homebrew casks grouped by host: common casks plus the active profile's own group.
{ host }:
let
  casks = {
    common = [
      "1password"
      "1password-cli"
      "chatgpt"
      "claude"
      "cmux"
      "codex-app"
      "cursor"
      "cursor-cli"
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
      "rectangle"
      "scroll-reverser"
      "slack"
      "stablyai/orca/orca"
      "thebrowsercompany-dia"
    ];
    personal = [
      "adobe-creative-cloud"
      "brave-browser"
      "vlc"
      "voiceink"
    ];
    work = [
      "zoom"
    ];
  };
in
casks.common ++ casks.${host.profile}
