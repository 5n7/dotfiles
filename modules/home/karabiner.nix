# Karabiner rewrites karabiner.json at runtime, so it is copied as a writable file
# instead of linked read-only. Each `darwin-rebuild switch` overwrites GUI edits;
# make changes in modules/home/karabiner.json.
{ lib, ... }:
{
  home.activation.karabinerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.config/karabiner"
    run cp -f ${./karabiner.json} "$HOME/.config/karabiner/karabiner.json"
    run chmod u+w "$HOME/.config/karabiner/karabiner.json"
  '';
}
