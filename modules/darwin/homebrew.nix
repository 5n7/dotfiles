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
      "datadog-labs/pack"
      "k1low/tap"
      "stablyai/orca"
      "vjeantet/tap"
    ];

    brews = import ../../hosts/brews.nix { inherit host; };

    casks = import ../../hosts/casks.nix { inherit host; };

    masApps = import ../../hosts/mas.nix { inherit host; };

    # Homebrew 6.0 requires non-official taps to be explicitly trusted before
    # `brew bundle` will load formulae/casks from them. nix-darwin's homebrew
    # module doesn't expose a `trusted` option yet, so declare trust for the
    # specific items we use (not the whole tap) via raw Brewfile syntax.
    # https://docs.brew.sh/Tap-Trust
    # Taps and their trust declarations stay unconditional; only the formulae
    # and casks themselves are scoped per host profile.
    extraConfig = ''
      tap "datadog-labs/pack", trusted: { formula: "pup" }
      tap "k1low/tap", trusted: { formula: "mo" }
      tap "stablyai/orca", trusted: { cask: "orca" }
      tap "vjeantet/tap", trusted: { formula: "alerter" }
    '';
  };
}
