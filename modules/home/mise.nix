# `mise use -g` and `mise upgrade --bump` rewrite the global `[tools]` table, so
# config.toml links out of the store into the checkout, where the changes can be
# committed. `[settings]` stay declarative in conf.d, which takes precedence over
# config.toml.
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
      # A shim for a tool that is installed but not active here falls back to PATH
      # minus mise's shims, which lands on aqua's proxy; aqua does the same in
      # reverse, so the two exec each other forever (e.g. shellcheck from bashls).
      activate_shims = false;
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
    # modules/home/zsh/deferred.zsh activates mise under zsh-defer instead, to keep
    # shell startup fast.
    enableZshIntegration = false;
  };

  xdg.configFile."mise/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/mise/config.toml";

  xdg.configFile."mise/conf.d/00-settings.toml".source = settingsConfig;
}
