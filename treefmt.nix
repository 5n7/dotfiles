{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  # Nix (RFC-style).
  programs.nixfmt.enable = true;

  # Lua (Neovim config). stylua defaults (tabs) already match the existing files.
  programs.stylua.enable = true;

  # Shell. With no indent flags, shfmt respects .editorconfig (shell = 4 spaces).
  # compinit.zsh uses zsh glob qualifiers that shfmt cannot parse, so skip it.
  settings.formatter.shfmt = {
    command = "${pkgs.shfmt}/bin/shfmt";
    options = [ "-w" ];
    includes = [
      "*.sh"
      "*.bash"
      "*.zsh"
    ];
    excludes = [ "modules/home/zsh/compinit.zsh" ];
  };

  # JSON / Markdown / TOML / YAML via dprint, using nixpkgs-packaged plugins so the
  # wasm is resolved from nixpkgs (offline; works in the nix flake check sandbox).
  programs.dprint = {
    enable = true;
    includes = [
      "*.json"
      "*.md"
      "*.toml"
      "*.yaml"
      "*.yml"
    ];
    excludes = [ "**/*-lock.json" ];
    settings.plugins = pkgs.dprint-plugins.getPluginList (
      p: with p; [
        dprint-plugin-json
        dprint-plugin-markdown
        dprint-plugin-toml
        g-plane-pretty_yaml
      ]
    );
  };
}
