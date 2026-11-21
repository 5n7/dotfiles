# Herdr app

This directory configures the Herdr desktop app (`herdr-app`). The herdr TUI is configured separately in `../herdr.nix`.

The installed app documents itself, and those docs follow its version. Read them before changing anything rather than working from memory:

1. Run `herdr-app --skill` for driving the window and where `hc` fits.
2. Read `~/.config/herdr-app/AGENTS.md`, and `herdr.d.ts` and `gpui-kit.d.ts` beside it, for keys, settings, themes, layouts and mods. The app rewrites all three on every start, so never edit them.

## Where the configuration lives

`default.nix` owns the app's files. Change them here, never under `~/.config/herdr-app`:

- `keys.json` and `settings.json` are copied in as writable files on every switch, so edits made in the app or by hand last only until the next one.
- `keys.json` replaces the app's keymap rather than extending it, so `default.nix` writes all of it. As in the herdr TUI, herdr's own actions go through the Ctrl+F prefix alone; beyond it, the keymap holds only Settings, Quit, copy and paste. After an app update, look for new defaults worth adopting: with the app quit, move `~/.config/herdr-app/keys.json` aside, start the app, which writes its defaults to the missing file, compare them with the keymap in `default.nix`, and ask the user to switch to restore the managed file.
- Own mods live in the [herdr-extensions](https://github.com/5n7/herdr-extensions) flake, which builds each one into a folder. `default.nix` lists the installed mods in `mods`. `./mods-sync.sh` copies each one into `mods/<name>/` as real files on every switch and removes the ones dropped from the list. It leaves alone any folder it did not create, including the app's own mods and mods made by hand. Real files let a mod import its other modules, and the folder stays writable for the `jsconfig.json` and `gpui-kit.d.ts` the app writes. A third-party mod is a pinned non-flake input whose folder goes in `mods` the same way. Read its code before adding it.
- Ctrl+F is a tmux-style prefix, implemented by herdr-extensions' `mod-prefix`. Its second keys are listed in `prefix-keys.nix`. The package turns them into the mod's `card.json` and into `keymap`, the `"mod:prefix"` section of `keys.json`.
- The prefix's y and u open the `pick` mod. It starts its picker in a hidden terminal and puts it in the focused pane with `terminal.show`, so the hints sit on that terminal's own cells.
- Layouts live in `layouts/<name>.nix`. `default.nix` lists each one in `layouts` and copies it in as a writable `layouts/<name>.json` on every switch, as it does `keys.json`. The app replaces its own layouts on every start, so changes go in these. `custom` is the app's `main` without the sidebar's brand and footer, with the `usage` mod at the sidebar's foot. It doesn't follow later changes to `main`. Which layout shows is the app's own state, so run `herdr-app do layout.switch '{"name":"custom"}'` once on each machine. A switch never removes a layout dropped from the list, so delete its file by hand.
- Themes live in `themes/<name>.nix`. `default.nix` lists each one and links it as `themes/<name>.json`, and `settings.json`'s `theme` picks one by that name.

## Checking a change

1. A mod's code changes in herdr-extensions, whose AGENTS.md covers checking it. To build this flake against an unpushed checkout, add `--override-input herdr-extensions ~/src/github.com/5n7/herdr-extensions`.
2. Build with `darwin-rebuild build --flake .#personal`. Applying needs `sudo darwin-rebuild switch --flake .#personal`, which the user runs.
3. After the switch, run `herdr-app check ~/.config/herdr-app/mods/<name>` and `herdr-app status`, then `herdr-app shot` and look at the picture.
