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
    ];
    personal = [
    ];
    work = [
    ];
  };
in
brews.common ++ brews.${host.profile}
