# Plugin catalog linked into the herdr server on activation.
#
# Two build strategies:
# - mkReleasePlugin: upstream source plus a published aarch64-darwin binary.
#   `herdr plugin install` would clone into ~/.config/herdr/plugins/github and
#   run the manifest's [[build]] step in place, inheriting launchd's PATH (no
#   cargo, no bun). Linking a store path skips that. Attribute names are plugin
#   ids from each herdr-plugin.toml.
# - mkBunStandalonePlugin: a Bun TypeScript entrypoint compiled into a standalone
#   executable, so the Herdr server does not need Bun in its launchd PATH.
{
  inputs,
  lib,
  pkgs,
}:
let
  inherit (import ./plugin-builders.nix { inherit lib pkgs; })
    mkBunStandalonePlugin
    mkReleasePlugin
    ;

  plugin =
    id: package: enabled:
    assert lib.assertMsg (package.pluginId == id) ''
      catalog id ${id} does not match package manifest id ${package.pluginId}
    '';
    {
      inherit package enabled;
    };
in
{
  herdr-navigator = plugin "herdr-navigator" (mkReleasePlugin {
    pname = "herdr-navigator";
    version = "0.3.5";
    src = inputs.herdr-navigator;
    url = "https://github.com/thanhdat77/herdr-navigator/releases/download/v0.3.5/herdr-navigator-macos-aarch64.tar.gz";
    hash = "sha256-0LQE2/tp9M9RhVIadLnkOchIs6tnxueskwLog7fwzBM=";
    # Tarball nests the binary one directory down.
    tarMember = "herdr-navigator/herdr-navigator";
    binaryPath = "target/release/herdr-navigator";
    expectedId = "herdr-navigator";
  }) true;

  # The manifest's own [[build]] step (./scripts/install-binary.sh) only
  # downloads this release tarball, so it is skipped and the binary installed
  # here instead.
  "rmarganti.herdr-pluck" = plugin "rmarganti.herdr-pluck" (mkReleasePlugin {
    pname = "herdr-pluck";
    version = "0.3.1";
    src = inputs.herdr-pluck;
    url = "https://github.com/rmarganti/herdr-pluck/releases/download/v0.3.1/herdr-pluck-v0.3.1-aarch64-apple-darwin.tar.gz";
    hash = "sha256-TNg86ZPjYF+ddarrK3oV9QPoDvTI+AQW55vqdyzmnH4=";
    tarMember = "herdr-pluck";
    binaryPath = "bin/herdr-pluck";
    expectedId = "rmarganti.herdr-pluck";
  }) true;

  herdr-even-layout = plugin "herdr-even-layout" (mkBunStandalonePlugin {
    pname = "herdr-even-layout";
    version = "0.1.0";
    src = inputs.herdr-plugins;
    pluginRoot = "plugins/herdr-even-layout";
    entrypoint = "plugins/herdr-even-layout/src/main.ts";
    expectedId = "herdr-even-layout";
  }) true;
}
