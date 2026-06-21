# macOS security: authenticate `sudo` with Touch ID so `darwin-rebuild switch`
# (which requires root for system activation) doesn't prompt for a password.
{ ... }:
{
  security.pam.services.sudo_local = {
    # Reattach the process to the user's GUI bootstrap session so Touch ID
    # works for sudo inside tmux/screen (e.g. cmux), where it otherwise falls
    # back to a password prompt despite showing the popup.
    reattach = true;
    touchIdAuth = true;
  };
}
