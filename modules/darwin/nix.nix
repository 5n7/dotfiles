# Nix daemon settings and nixpkgs configuration.
{
  inputs,
  lib,
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

  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "claude";
  # Required by colima, which pulls lima-full and lima-additional-guestagents.
  nixpkgs.config.permittedInsecurePackages = [
    "lima-additional-guestagents-1.2.2"
    "lima-full-1.2.2"
  ];
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
