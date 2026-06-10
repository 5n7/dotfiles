# Neovim editor configuration.
{
  config,
  dotfilesDir,
  ...
}:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/nvim";
}
