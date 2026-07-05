# ccstatusline statusline for Claude Code. The binary is built by Nix here (from
# the npm tarball) and installed as `ccstatusline`; the runtime-managed
# settings.json references it by name in its statusLine command. The settings
# file and the custom widget scripts it references live under ./ccstatusline.
{ config, pkgs, ... }:
let
  version = "2.2.22";
  ccstatusline = pkgs.stdenvNoCC.mkDerivation {
    pname = "ccstatusline";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/ccstatusline/-/ccstatusline-${version}.tgz";
      hash = "sha256-FKDBeocIjiP4xXxNycTAJFlr7s+I8zm+gNv9IchcsQA=";
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

  # Shared, sourced by the widgets — no exec bit.
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
  xdg.configFile."ccstatusline/status-claude.sh" = {
    source = ./ccstatusline/status-claude.sh;
    executable = true;
  };
}
