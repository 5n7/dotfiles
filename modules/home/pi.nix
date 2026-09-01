# pi coding agent. The package comes from packages.nix, and ~/.pi/agent/AGENTS.md
# from agents.nix; pi scans both ~/.agents/skills and ~/.pi/agent/skills natively,
# so the shared skills tree needs no link of its own here.
#
# settings.json is shared rather than owned. Nix declares the stable subset below
# and merges it into the file on activation; pi keeps the volatile runtime fields,
# which it rewrites on its own — setDefaultModelAndProvider calls save() on every
# ctrl+p model cycle, so defaultModel, defaultProvider, defaultThinkingLevel, and
# lastChangelogVersion have to stay undeclared or a switch would undo whichever
# model was last picked. The two coexist in one file because the merge overwrites
# only the declared keys.
#
# That leaves ~/.pi/agent/extensions/, which pi auto-discovers on start and which
# no pi subcommand writes to — `pi install` only touches settings.json and
# ~/.pi/agent/npm/ — so Nix can own its contents without racing the CLI.
{
  lib,
  pkgs,
  ...
}:
let
  # Extension name -> source file. pi runs extension TypeScript through jiti, so a
  # dependency-free single-file .ts needs no build step and home.file is enough to
  # install one. Empty for now, which makes the home.file below a no-op.
  extensions = { };

  # The declared subset of ~/.pi/agent/settings.json, merged in by
  # pi-settings-merge.sh. Anything pi writes back at runtime belongs to pi; see
  # the header.
  settings = {
    theme = "dark";

    # npm/git packages, written as the source strings `pi install` takes. Nothing
    # here runs `pi install`: pi installs a declared-but-missing package itself on
    # startup, so activation never touches the network and the flake pins nothing
    # about them.
    #
    # Dropping a package from this list removes it from settings.json but leaves
    # its tree under ~/.pi/agent/npm/; delete that directory to rebuild from the
    # declared state.
    packages = [
      "npm:@juicesharp/rpiv-ask-user-question"
      "npm:@juicesharp/rpiv-btw"
      "npm:@juicesharp/rpiv-todo"
      "npm:@tintinweb/pi-subagents"
      "npm:pi-background-tasks"
      "npm:pi-lens"
      "npm:pi-mcp-adapter"
      "npm:pi-review"
      "npm:pi-web-access"
    ];
  };

  # The merge lives in its own file so writeShellApplication runs shellcheck over
  # it at build time and so it can be run by hand outside activation.
  pi-settings-merge = pkgs.writeShellApplication {
    name = "pi-settings-merge";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./pi-settings-merge.sh;
  };
in
{
  home.file = lib.mapAttrs' (
    name: source: lib.nameValuePair ".pi/agent/extensions/${name}.ts" { inherit source; }
  ) extensions;

  # One `run` around the whole script, so `--dry-run` skips the side effect
  # entirely — the earlier inline version could only wrap its final `cp`, since a
  # redirect inside `run` fires even in dry-run mode.
  home.activation.piSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe pi-settings-merge} ${lib.escapeShellArg (builtins.toJSON settings)}
  '';
}
