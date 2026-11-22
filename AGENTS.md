# dotfiles

## Applying changes

Build with `darwin-rebuild build --flake .#personal`. Apply with `sudo darwin-rebuild switch --flake .#personal` yourself, without asking first. Sudo authenticates with Touch ID, which `modules/darwin/security.nix` sets up. Switch whenever you need a change applied to check or use it, and say in the report that you switched.
