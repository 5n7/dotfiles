# Aggregates the home-manager modules and shared session environment.
{
  config,
  host,
  ...
}:
let
  inherit (config.home) homeDirectory;

  aquaRoot = "${config.xdg.dataHome}/aqua";
  dotfilesDir = "${homeDirectory}/src/github.com/5n7/dotfiles";
  goRoot = "${config.xdg.dataHome}/go";
in
{
  imports = [
    ./ccstatusline.nix
    ./claude-code.nix
    ./editor.nix
    ./git.nix
    ./gpg.nix
    ./karabiner.nix
    ./mise.nix
    ./packages.nix
    ./shell.nix
    ./terminal.nix
    ./wm.nix
  ];

  # Single source for the live dotfiles checkout, consumed here (DOTFILES_DIR) and
  # by editor.nix's out-of-store nvim symlink.
  _module.args.dotfilesDir = dotfilesDir;

  home.username = host.username;
  home.homeDirectory = "/Users/${host.username}";
  home.stateVersion = "25.11";

  home.sessionPath = [
    "/etc/profiles/per-user/${host.username}/bin"
    "/run/current-system/sw/bin"
    "${aquaRoot}/bin"
    "/opt/homebrew/bin"
    # Replaces sourcing path.zsh.inc; harmless if the gcloud SDK dir is absent.
    "/opt/homebrew/share/google-cloud-sdk/bin"
    "${goRoot}/bin"
  ];

  home.sessionVariables = {
    AQUA_GLOBAL_CONFIG = "${config.xdg.configHome}/aqua";
    AQUA_ROOT_DIR = aquaRoot;
    CLAUDE_CODE_MAX_OUTPUT_TOKENS = "64000";
    CLAUDE_CODE_NO_FLICKER = "1";
    DISABLE_TELEMETRY = "1";
    DOTFILES_DIR = dotfilesDir;
    EDITOR = "nvim";
    GHQ_ROOT = "${homeDirectory}/src";
    GOPATH = goRoot;
    GOPRIVATE = host.goPrivate;
    HOMEBREW_NO_ENV_HINTS = "1";
  };

  programs.home-manager.enable = true;
}
