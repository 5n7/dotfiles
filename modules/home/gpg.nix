# GPG toolchain for commit signing; pinentry-mac handles passphrase prompts.
{ pkgs, ... }:
{
  programs.gpg.enable = true;

  home.packages = [ pkgs.pinentry_mac ];

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
  };
}
