{ pkgs-unstable, ... }:
{
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;

  # stylua's defaults (tabs) already match the Neovim config.
  programs.stylua.enable = true;

  # With no indent flags, shfmt respects .editorconfig (4 spaces).
  # compinit.zsh uses zsh glob qualifiers that shfmt cannot parse, so skip it.
  settings.formatter.shfmt = {
    command = "${pkgs-unstable.shfmt}/bin/shfmt";
    options = [ "-w" ];
    includes = [
      "*.bash"
      "*.sh"
      "*.zsh"
    ];
    excludes = [ "modules/home/zsh/compinit.zsh" ];
  };

  # Lazy writes lazy-lock.json itself.
  programs.oxfmt = {
    enable = true;
    excludes = [ "**/*-lock.json" ];
  };
  # The module's include list leaves out TOML, which oxfmt also formats.
  settings.formatter.oxfmt.includes = [ "*.toml" ];
}
