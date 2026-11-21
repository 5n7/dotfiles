# Aggregates the darwin-level modules.
{ ... }:
{
  # No darwin module for Karabiner-Elements: its cask (hosts/casks.nix) manages the
  # DriverKit daemon and launchd services, and modules/home/karabiner.nix the config.
  imports = [
    ./homebrew.nix
    ./nix.nix
    ./security.nix
    ./shell.nix
    ./system.nix
  ];
}
