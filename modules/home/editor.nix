# Neovim editor configuration.
{
  config,
  dotfilesDir,
  pkgs-unstable,
  ...
}:
{
  programs.neovim = {
    enable = true;
    package = pkgs-unstable.neovim-unwrapped;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Every plugin in .config/nvim is lua, so the ruby and python3 providers only
    # add an interpreter each to the closure. These are 26.05's defaults; setting
    # them explicitly adopts the new behaviour while home.stateVersion stays 25.11.
    withPython3 = false;
    withRuby = false;

    # home-manager puts its provider settings in ~/.config/nvim/init.lua, which
    # here is an out-of-store symlink into the checkout below; writing into it
    # fails the "outside $HOME" check in home-manager's file builder. Sideloading
    # passes the same lua to the wrapper as `--cmd 'lua dofile(...)'`, so it runs
    # before the checkout's own init.lua and nothing is written into the symlink.
    sideloadInitLua = true;
  };

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/nvim";
}
