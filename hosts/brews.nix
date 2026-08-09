# Homebrew formulae grouped by host: common brews plus the active profile's own group.
{ host }:
let
  brews = {
    common = [
      "aqua"
      "datadog-labs/pack/pup"
      "googleworkspace-cli"
      "k1low/tap/mo"
      "mas"

      # Formula deps of the gcloud-cli cask. `brew bundle` cleanup ignores cask
      # dependencies, so without these it tries (and fails) to uninstall them on
      # every activation.
      "ca-certificates"
      "mpdecimal"
      "openssl@3"
      "readline"
      "sqlite"
      "xz"
    ];
    personal = [
      "MikkoParkkola/tap/mcp-gateway"
    ];
    work = [
    ];
  };
in
brews.common ++ brews.${host.profile}
