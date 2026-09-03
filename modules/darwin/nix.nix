# Nix daemon settings and nixpkgs configuration.
{
  inputs,
  system,
  ...
}:
{
  # Runs weekly on Sunday at 03:15 by default.
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";

  nix.optimise.automatic = true;

  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = system;
  nixpkgs.overlays = [
    inputs.nix-claude-code.overlays.default
    # herdr is not in nixpkgs, so surface its flake package as `pkgs.herdr` for
    # any module that needs it. Its own overlay is not used because that one
    # composes rust-overlay into the global package set.
    (_: _: { herdr = inputs.herdr.packages.${system}.default; })
  ];

  system.stateVersion = 5;
}
