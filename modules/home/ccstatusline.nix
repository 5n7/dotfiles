# Built from the npm tarball and installed as `ccstatusline`, the name Claude
# Code's runtime-managed settings.json calls in its statusLine command.
{ config, pkgs, ... }:
let
  version = "2.2.30";
  ccstatusline = pkgs.stdenvNoCC.mkDerivation {
    pname = "ccstatusline";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/ccstatusline/-/ccstatusline-${version}.tgz";
      hash = "sha256-NWR5zB/3Nbdmvrom7ploLN7xQ8YDsPTx/X5qVugn12k=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/ccstatusline
      cp -r . $out/lib/ccstatusline

      makeWrapper ${pkgs.bun}/bin/bun $out/bin/ccstatusline \
        --add-flags $out/lib/ccstatusline/dist/ccstatusline.js

      runHook postInstall
    '';

    meta.mainProgram = "ccstatusline";
  };
in
{
  home.packages = [ ccstatusline ];

  # settings.json carries \u escapes (defaultSeparator) that a Nix attrset cannot
  # express, so keep it as JSON and template the per-host config path in: each
  # commandPath is @configHome@/ccstatusline/<script>.sh.
  xdg.configFile."ccstatusline/settings.json".text =
    builtins.replaceStrings [ "@configHome@" ] [ config.xdg.configHome ]
      (builtins.readFile ./ccstatusline/settings.json);

  # Sourced by the widgets, so no exec bit.
  xdg.configFile."ccstatusline/lib.sh".source = ./ccstatusline/lib.sh;

  # ccstatusline executes each widget commandPath directly, so the exec bit is required.
  xdg.configFile."ccstatusline/context-bar.sh" = {
    source = ./ccstatusline/context-bar.sh;
    executable = true;
  };
  xdg.configFile."ccstatusline/cwd-path.sh" = {
    source = ./ccstatusline/cwd-path.sh;
    executable = true;
  };
  xdg.configFile."ccstatusline/model-color.sh" = {
    source = ./ccstatusline/model-color.sh;
    executable = true;
  };
}
