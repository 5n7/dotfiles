# Aggregates the darwin-level modules.
{ ... }:
{
  # Karabiner-Elements is installed via the karabiner-elements cask (hosts/casks.nix),
  # which manages its own DriverKit daemon and launchd services; its user config is
  # handled by modules/home/karabiner.nix — so no darwin-level module is needed.
  imports = [
    ./cmux.nix
    ./homebrew.nix
    ./nix.nix
    ./security.nix
    ./system.nix
  ];
}
