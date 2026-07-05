{ pkgs-unstable, ... }:
{
  projectRootFile = "flake.nix";

  # Nix (RFC-style).
  programs.nixfmt.enable = true;

  # Lua (Neovim config). stylua defaults (tabs) already match the existing files.
  programs.stylua.enable = true;

  # Shell. With no indent flags, shfmt respects .editorconfig (shell = 4 spaces).
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

  # JavaScript, JSON, Markdown, TOML and YAML. Lazy writes lazy-lock.json itself.
  programs.oxfmt = {
    enable = true;
    excludes = [ "**/*-lock.json" ];
  };
  # Added to the module's own list, which leaves out TOML though oxfmt formats it.
  settings.formatter.oxfmt.includes = [ "*.toml" ];
}
