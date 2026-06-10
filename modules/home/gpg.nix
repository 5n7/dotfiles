# GPG toolchain for commit signing; pinentry-mac handles passphrase prompts.
{ pkgs, ... }:
{
  programs.gpg.enable = true;

  home.packages = [ pkgs.pinentry_mac ];

  # The gpg-agent module writes ~/.gnupg/gpg-agent.conf (pinentry-program plus
  # cache TTLs) and manages the agent.
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
  };
}
