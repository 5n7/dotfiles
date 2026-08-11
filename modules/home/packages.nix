# User packages grouped by host: common packages plus the active profile's own group.
{
  host,
  inputs,
  pkgs,
  pkgs-unstable,
  system,
  ...
}:
let
  docker-client = pkgs.docker_29.override { clientOnly = true; };
  herdr = inputs.herdr.packages.${system}.default;

  packages = with pkgs; {
    common = [
      bat
      pkgs-unstable.buf
      pkgs-unstable.codex
      colima
      docker-client
      docker-compose
      pkgs-unstable.dua
      eza
      pkgs-unstable.fd
      ffmpeg
      pkgs-unstable.gawk
      ghostscript
      pkgs-unstable.ghq
      pkgs-unstable.git-wt
      pkgs-unstable.glow
      gnused
      pkgs-unstable.gomi
      herdr
      imagemagick
      pkgs-unstable.jnv
      jq
      pkgs-unstable.ko
      pkgs-unstable.krew
      pkgs-unstable.kubectl
      libpq
      mmv-go
      ripgrep
      pkgs-unstable.skaffold
      stylua
      pkgs-unstable.tree-sitter
      wget
      xcodegen
      pkgs-unstable.yazi
      yq
    ];
    personal = [
      # unstable's wrangler 4.93.0 fails to build (flaky EBADF during its DTS build),
      # so keep it on stable until nixpkgs-unstable ships a buildable revision.
      wrangler
    ];
    work = [
    ];
  };
in
{
  home.packages = packages.common ++ packages.${host.profile};
}
