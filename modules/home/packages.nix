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
      btop
      buf
      pkgs-unstable.codex
      colima
      docker-client
      docker-compose
      pkgs-unstable.dua
      eza
      fd
      ffmpeg
      gawk
      ghostscript
      pkgs-unstable.ghq
      pkgs-unstable.git-wt
      glow
      gnused
      gomi
      imagemagick
      jnv
      jq
      pkgs-unstable.ko
      krew
      kubectl
      libpq
      mmv-go
      ripgrep
      pkgs-unstable.skaffold
      stylua
      pkgs-unstable.tree-sitter
      wget
      xcodegen
      yazi
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
