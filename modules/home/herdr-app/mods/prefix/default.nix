# The prefix's second keys, for ./main.js: the "mod:prefix" section of
# keys.json, and the card.json the mod reads to show them.
{ lib, pkgs }:
let
  # The keys after the prefix, grouped as the card shows them. A key is GPUI's
  # name for it. `run` is the app command for the row's keys, or maps each key
  # to its own. `action` names one of main.js's own `ACTIONS` instead; an
  # unknown one does nothing.
  groups = [
    {
      name = "Tabs";
      rows = [
        {
          keys = [ "c" ];
          label = "New tab";
          run = "tab.new";
        }
        {
          keys = [ "tab" ];
          label = "Next tab";
          run = "tab.next";
        }
        {
          keys = [ "shift-tab" ];
          label = "Previous tab";
          run = "tab.prev";
        }
        {
          label = "Go to tab";
          run = lib.genAttrs (map toString (lib.range 1 9)) (key: "tab.select:${key}");
        }
        {
          keys = [ "shift-t" ];
          label = "Rename tab";
          run = "tab.rename";
        }
        {
          keys = [ "shift-x" ];
          label = "Close tab";
          run = "tab.close";
        }
      ];
    }
    {
      name = "Panes";
      rows = [
        {
          keys = [ "\\" ];
          label = "Split right";
          run = "pane.split:right";
        }
        {
          keys = [ "-" ];
          label = "Split down";
          run = "pane.split:down";
        }
        {
          label = "Focus";
          run = {
            h = "pane.go:left";
            j = "pane.go:down";
            k = "pane.go:up";
            l = "pane.go:right";
          };
        }
        {
          keys = [ "z" ];
          label = "Zoom";
          run = "pane.zoom";
        }
        {
          keys = [ "x" ];
          label = "Close pane";
          run = "pane.close";
        }
      ];
    }
    {
      name = "Spaces";
      rows = [
        {
          keys = [ "shift-n" ];
          label = "New space";
          run = "space.new";
        }
        {
          keys = [ "shift-g" ];
          label = "New worktree";
          action = "worktree";
        }
        {
          keys = [ "n" ];
          label = "Next space";
          run = "space.next";
        }
        {
          keys = [ "p" ];
          label = "Previous space";
          run = "space.prev";
        }
        {
          keys = [ "shift-w" ];
          label = "Rename space";
          run = "space.rename";
        }
        {
          keys = [ "shift-d" ];
          label = "Close space";
          run = "space.close";
        }
      ];
    }
    {
      name = "Jumps";
      rows = [
        {
          keys = [ "space" ];
          label = "Go to…";
          run = "mod.open:picker";
        }
        {
          keys = [ "o" ];
          label = "Needs you";
          action = "attention";
        }
      ];
    }
    # The herdr TUI's pluck keys: y as yank, u as url.
    {
      name = "Screen";
      rows = [
        {
          keys = [ "y" ];
          label = "Copy text";
          action = "pluck";
        }
        {
          keys = [ "u" ];
          label = "Open URL";
          action = "open-url";
        }
      ];
    }
    {
      name = "Window";
      rows = [
        {
          keys = [ "b" ];
          label = "Sidebar";
          run = "layout.toggle:sidebar";
        }
      ];
    }
  ];

  # A row's keys, each with what it sends nextCommand() after "prefix.". A
  # map's keys come sorted, which suits 1-9 and h j k l.
  bindings =
    row:
    if lib.isAttrs (row.run or null) then
      lib.mapAttrsToList (key: run: {
        inherit key;
        command = "run:${run}";
      }) row.run
    else
      map (key: {
        inherit key;
        command = if row ? action then row.action else "run:${row.run}";
      }) row.keys;

  allBindings = lib.concatMap bindings (lib.concatMap (group: group.rows) groups);
in
{
  # Every key the prefix knows goes to the mod, which runs the command and
  # closes. A second Ctrl+F sends a literal one to the program.
  keymap =
    assert lib.assertMsg (lib.allUnique (
      [ "ctrl-f" ] ++ map (binding: binding.key) allBindings
    )) "herdr-app prefix: a key is bound twice";
    {
      "ctrl-f" = "prefix.send-prefix";
    }
    // lib.listToAttrs (
      map (binding: lib.nameValuePair binding.key "prefix.${binding.command}") allBindings
    );

  # What ? shows. A row's `command` is its first key's; main.js uses it only to
  # tell rows apart.
  card = (pkgs.formats.json { }).generate "herdr-app-prefix-card.json" (
    map (group: {
      inherit (group) name;
      rows = map (
        row:
        let
          rowBindings = bindings row;
        in
        {
          inherit (row) label;
          keys = map (binding: binding.key) rowBindings;
          inherit (lib.head rowBindings) command;
        }
      ) group.rows;
    }) groups
  );
}
