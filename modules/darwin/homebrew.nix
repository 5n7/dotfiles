# Homebrew packages, taps, and casks.
{ host, ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "uninstall";
    };

    taps = [
      "BarutSRB/tap"
      "datadog-labs/pack"
      "k1low/tap"
    ];

    brews = import ../../hosts/brews.nix { inherit host; };

    casks = import ../../hosts/casks.nix { inherit host; };

    masApps = import ../../hosts/mas.nix { inherit host; };
  };
}
