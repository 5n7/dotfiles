# Manage Karabiner-Elements user config. Karabiner rewrites karabiner.json at
# runtime, which conflicts with home-manager's read-only symlinks, so copy it as a
# real writable file on each activation instead. GUI edits are overwritten on the
# next `darwin-rebuild switch` — edit modules/home/karabiner.json to make changes.
{ lib, ... }:
{
  home.activation.karabinerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.config/karabiner"
    run cp -f ${./karabiner.json} "$HOME/.config/karabiner/karabiner.json"
    run chmod u+w "$HOME/.config/karabiner/karabiner.json"
  '';
}
