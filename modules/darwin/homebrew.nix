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
      "k1low/tap"
      "manaflow-ai/cmux"
      "stablyai/orca"
    ];

    brews = [
      "aqua"
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

    casks = import ../../hosts/casks.nix { inherit host; };

    masApps = {
      RunCat = 1429033973;
      Xcode = 497799835;
    };

    # Homebrew 6.0 requires non-official taps to be explicitly trusted before
    # `brew bundle` will load formulae/casks from them. nix-darwin's homebrew
    # module doesn't expose a `trusted` option yet, so declare trust for the
    # specific items we use (not the whole tap) via raw Brewfile syntax.
    # https://docs.brew.sh/Tap-Trust
    extraConfig = ''
      tap "k1low/tap", trusted: { formula: "mo" }
      tap "manaflow-ai/cmux", trusted: { cask: "cmux" }
      tap "stablyai/orca", trusted: { cask: "orca" }
    '';
  };
}
