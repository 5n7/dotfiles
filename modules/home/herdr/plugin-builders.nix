{
  lib,
  pkgs,
}:
{
  mkReleasePlugin =
    {
      pname,
      version,
      src,
      url,
      hash,
      tarMember,
      binaryPath,
    }:
    let
      manifest = builtins.fromTOML (builtins.readFile "${src}/herdr-plugin.toml");
      binary = pkgs.runCommand "${pname}-binary" { } ''
        tar -xzOf ${pkgs.fetchurl { inherit url hash; }} ${lib.escapeShellArg tarMember} > $out
      '';
    in
    assert lib.assertMsg (manifest.version == version) ''
      ${pname}: package version ${version} does not match manifest version ${manifest.version}
    '';
    pkgs.runCommand "${pname}-${version}" { passthru.pluginId = manifest.id; } ''
      cp -R ${src} $out
      chmod -R u+w $out
      install -Dm555 ${binary} $out/${binaryPath}
    '';
}
