# Neovim editor configuration.
{
  config,
  dotfilesDir,
  pkgs,
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

    # LSP servers (lsp/*.lua) and snacks.image's Mermaid converter, on the
    # wrapper's PATH rather than the user profile because nothing outside nvim
    # needs them.
    extraPackages = [
      pkgs.bash-language-server
      pkgs-unstable.gopls
      pkgs.lua-language-server
      pkgs.mermaid-cli
      pkgs.nixd
      pkgs-unstable.rust-analyzer
      pkgs.vscode-langservers-extracted # jsonls
      pkgs-unstable.vtsls
      pkgs.yaml-language-server
    ];

    # mermaid-cli renders through Chrome, which nixpkgs doesn't build for macOS, so
    # it uses the google-chrome cask.
    extraWrapperArgs = [
      "--set"
      "PUPPETEER_EXECUTABLE_PATH"
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    ];

    # Every plugin is Lua, so these providers only add interpreters to the closure.
    # 26.05 defaults to this, but only from home.stateVersion 26.05 (ours is 25.11).
    withPython3 = false;
    withRuby = false;

    # home-manager writes its provider settings into ~/.config/nvim/init.lua, an
    # out-of-store symlink into the checkout here, which fails its "outside $HOME"
    # check. Sideloading passes the same Lua as `--cmd 'lua dofile(...)'` instead,
    # so it runs before the checkout's init.lua.
    sideloadInitLua = true;
  };

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/nvim";
}
