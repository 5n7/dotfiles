# User packages installed via home-manager.
{ pkgs, pkgs-unstable, ... }:
let
  docker-client = pkgs.docker_29.override { clientOnly = true; };
in
{
  home.packages = with pkgs; [
    bat
    buf
    pkgs-unstable.codex
    colima
    docker-client
    docker-compose
    dua
    eza
    fd
    ffmpeg
    gawk
    ghostscript
    ghq
    pkgs-unstable.git-wt
    glow
    gnused
    gomi
    imagemagick
    jnv
    jq
    ko
    krew
    kubectl
    libpq
    mmv-go
    ripgrep
    skaffold
    tree-sitter
    wget
    xcodegen
    yazi
    yq
  ];
}
