# Homebrew packages, taps, and casks.
{ host, ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "uninstall";
      # Homebrew 4.7+ requires an explicit confirmation flag for `brew bundle
      # --cleanup`; nix-darwin does not pass one yet, so force it here.
      extraFlags = [ "--force-cleanup" ];
    };

    taps = [
      "datadog-labs/pack"
      "k1low/tap"
      "MikkoParkkola/tap"
      "stablyai/orca"
    ];

    brews = import ../../hosts/brews.nix { inherit host; };

    casks = import ../../hosts/casks.nix { inherit host; };

    masApps = {
      "RunCat Neo" = 6757801838;
      Xcode = 497799835;
    };

    # Homebrew 6.0 requires non-official taps to be explicitly trusted before
    # `brew bundle` will load formulae/casks from them. nix-darwin's homebrew
    # module doesn't expose a `trusted` option yet, so declare trust for the
    # specific items we use (not the whole tap) via raw Brewfile syntax.
    # https://docs.brew.sh/Tap-Trust
    # Taps and their trust declarations stay unconditional; only the formulae
    # and casks themselves are scoped per host profile (e.g. mcp-gateway is
    # installed on the personal profile only).
    extraConfig = ''
      tap "datadog-labs/pack", trusted: { formula: "pup" }
      tap "k1low/tap", trusted: { formula: "mo" }
      tap "MikkoParkkola/tap", trusted: { formula: "mcp-gateway" }
      tap "stablyai/orca", trusted: { cask: "orca" }
    '';
  };
}
