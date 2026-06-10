# macOS security: authenticate `sudo` with Touch ID so `darwin-rebuild switch`
# (which requires root for system activation) doesn't prompt for a password.
{ ... }:
{
  security.pam.services.sudo_local.touchIdAuth = true;
}
