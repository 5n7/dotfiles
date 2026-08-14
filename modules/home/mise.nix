# mise tool version manager. The global `[tools]` table is written at runtime by
# `mise use -g` / `mise upgrade --bump`, so config.toml is an out-of-store symlink
# into the checkout and its changes can be committed. mise's own `[settings]` stay
# declarative in conf.d, which mise reads with precedence over config.toml, so
# nothing here fights for config.toml. Per-project tool versions stay dynamic via
# per-repo `.mise.toml`.
{
  config,
  dotfilesDir,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  # A conf.d entry is a full mise config file, hence the `settings` table wrapper.
  settingsConfig = (pkgs.formats.toml { }).generate "00-settings.toml" {
    settings = {
      experimental = true;
      python.uv_venv_auto = true;
      status.missing_tools = "always";
    };
  };
in
{
  programs.mise = {
    enable = true;
    package = pkgs-unstable.mise;
    # Activation runs via modules/home/zsh/deferred.zsh under zsh-defer to
    # keep interactive shell startup fast; HM's default eager integration
    # would duplicate it.
    enableZshIntegration = false;
  };

  xdg.configFile."mise/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/mise/config.toml";

  xdg.configFile."mise/conf.d/00-settings.toml".source = settingsConfig;
}
