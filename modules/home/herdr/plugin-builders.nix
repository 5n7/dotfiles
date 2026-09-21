# Builders for upstream Herdr plugins linked from the Nix store.
{
  lib,
  pkgs,
}:
{
  mkBunStandalonePlugin =
    {
      pname,
      version,
      src,
      pluginRoot,
      entrypoint,
      expectedId,
    }:
    let
      manifest = builtins.fromTOML (builtins.readFile "${src}/${pluginRoot}/herdr-plugin.toml");
    in
    assert lib.assertMsg (manifest.id == expectedId) ''
      ${pname}: catalog id ${expectedId} does not match manifest id ${manifest.id}
    '';
    assert lib.assertMsg (manifest.version == version) ''
      ${pname}: package version ${version} does not match manifest version ${manifest.version}
    '';
    pkgs.runCommand "${pname}-${version}"
      {
        nativeBuildInputs = [
          pkgs.bun
          pkgs.darwin.cctools
          pkgs.darwin.sigtool
        ];
        passthru.pluginId = manifest.id;
      }
      ''
        cp -R ${src} source
        chmod -R u+w source
        cd source
        mkdir -p $out
        cp ${pluginRoot}/herdr-plugin.toml $out/herdr-plugin.toml
        bun build --compile --target=bun ${entrypoint} --outfile $out/plugin
        codesign --force --sign - $out/plugin
      '';

  mkReleasePlugin =
    {
      pname,
      version,
      src,
      url,
      hash,
      tarMember,
      binaryPath,
      expectedId,
    }:
    let
      manifest = builtins.fromTOML (builtins.readFile "${src}/herdr-plugin.toml");
      binary = pkgs.runCommand "${pname}-binary" { } ''
        tar -xzOf ${pkgs.fetchurl { inherit url hash; }} ${lib.escapeShellArg tarMember} > $out
      '';
    in
    assert lib.assertMsg (manifest.id == expectedId) ''
      ${pname}: catalog id ${expectedId} does not match manifest id ${manifest.id}
    '';
    assert lib.assertMsg (manifest.version == version) ''
      ${pname}: package version ${version} does not match manifest version ${manifest.version}
    '';
    pkgs.runCommand "${pname}-${version}" { passthru.pluginId = manifest.id; } ''
      cp -R ${src} $out
      chmod -R u+w $out
      install -Dm555 ${binary} $out/${binaryPath}
    '';
}
