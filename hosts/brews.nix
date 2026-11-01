# Homebrew formulae grouped by host: common brews plus the active profile's own group.
{ host }:
let
  brews = {
    common = [
      "aqua"
      {
        name = "datadog-labs/pack/pup";
        trusted = true;
      }
      {
        name = "k1low/tap/mo";
        trusted = true;
      }
      "mas"
    ];
    personal = [
      {
        name = "anomalyco/tap/opencode-v2";
        trusted = true;
      }
      "googleworkspace-cli"
    ];
    work = [
      {
        name = "metalbear-co/mirrord/mirrord";
        trusted = true;
      }
    ];
  };
in
brews.common ++ brews.${host.profile}
