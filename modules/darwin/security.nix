# Touch ID for sudo, so `darwin-rebuild switch`, which activates as root, doesn't
# ask for a password.
{ ... }:
{
  security.pam.services.sudo_local = {
    # Reattaches to the GUI session. Inside tmux or screen, Touch ID otherwise
    # shows its popup but still falls back to a password prompt.
    reattach = true;
    touchIdAuth = true;
  };
}
