# User packages grouped by host: common packages plus the active profile's own group.
{
  host,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  docker-client = pkgs.docker_29.override { clientOnly = true; };

  packages = with pkgs; {
    common = [
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
    personal = [
      wrangler
    ];
    work = [
    ];
  };
in
{
  home.packages = packages.common ++ packages.${host.profile};
}
