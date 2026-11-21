# The format is documented in herdr-extensions' mods/prefix/default.nix.
{ lib }:
[
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
        keys = [ "n" ];
        label = "Next agent";
        run = "agent.next";
      }
      {
        keys = [ "p" ];
        label = "Previous agent";
        run = "agent.prev";
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
        action = "pick";
      }
      {
        keys = [ "u" ];
        label = "Open URL or Markdown";
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
]
