# Herdr app

This directory configures the Herdr desktop app (`herdr-app`). The herdr TUI is configured separately in `../herdr.nix`.

The installed app documents itself, and those docs follow its version. Read them before changing anything rather than working from memory:

1. Run `herdr-app --skill` for driving the window and where `hc` fits.
2. Read `~/.config/herdr-app/AGENTS.md`, and `herdr.d.ts` and `gpui-kit.d.ts` beside it, for keys, settings, themes, layouts and mods. The app rewrites all three on every start, so never edit them.

## Where the configuration lives

`default.nix` owns the app's files. Change them here, never under `~/.config/herdr-app`:

- `keys.json` and `settings.json` are copied in as writable files on every switch, so edits made in the app or by hand last only until the next one.
- `keys.json` replaces the app's keymap rather than extending it, so `default.nix` writes all of it. As in the herdr TUI, herdr's own actions go through the Ctrl+F prefix alone; beyond it, the keymap holds only Settings, Quit, copy and paste. After an app update, look for new defaults worth adopting: with the app quit, move `~/.config/herdr-app/keys.json` aside, start the app, which writes its defaults to the missing file, compare them with the keymap in `default.nix`, and ask the user to switch to restore the managed file.
- Mods live in `mods/<name>/`. `default.nix` links each file on its own, so the app can write `jsconfig.json` and `gpui-kit.d.ts` beside them, and a new file needs its own entry there. A mod can't import a linked file, since the app refuses modules whose real path is outside the mod's folder, so a mod's code stays in its `main.js` and generated data is read at run time instead.
- Ctrl+F is a tmux-style prefix, implemented by `mods/prefix`. Its second keys are listed in `mods/prefix/default.nix`, which generates both the `"mod:prefix"` section of `keys.json` and the mod's `card.json`; the mod runs what arrives and draws the card.
- The prefix's y and u open `mods/pluck`, which starts the picker `pluck/` builds in a hidden terminal and puts it in the focused pane with `terminal.show`, so its hints sit on that terminal's own cells. The picker is a Bun program whose build runs its tests; `default.nix` links it as `mods/pluck/pluck`. Work a mod awaits, `hc` calls included, must run in a view that stays open: a task with `owner: null` outlives its view, but the app stops answering its calls.
- Themes live in `themes/<name>.nix`. `default.nix` lists each one and links it as `themes/<name>.json`, and `settings.json`'s `theme` picks one by that name.

## Checking a change

1. For a mod, copy its folder to the scratchpad and run `herdr-app check <folder>`. Never call a mod done without a passing check. The copy holds real files, so it can't catch a refused import of a linked one; the check after the switch can.
2. Build with `darwin-rebuild build --flake .#personal`. Applying needs `sudo darwin-rebuild switch --flake .#personal`, which the user runs.
3. After the switch, run `herdr-app check ~/.config/herdr-app/mods/<name>` and `herdr-app status`, then `herdr-app shot` and look at the picture.
