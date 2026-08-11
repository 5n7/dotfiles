# Terminal emulator (ghostty). It launches herdr directly, so ghostty is a
# single-surface host: herdr owns tabs, splits, scrollback, mouse, and the
# window title. ghostty's equivalents are dead weight here, because herdr
# emulates each pane's terminal and those escape sequences never reach ghostty.
{ lib, pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    # nixpkgs' ghostty is Linux-only (meta.platforms lists no darwin, and it
    # evaluates as unsupported), so the cask stays and Nix manages only the
    # config file.
    package = null;
    # Shell integration is off below, so HM's manual `source` block would inject
    # what ghostty is being told not to.
    enableZshIntegration = false;
    # Grouped by what each setting governs: appearance, then what the window
    # runs, then input. Related keys stay adjacent so a comment can refer to the
    # line above it.
    settings = {
      # Sets the ANSI palette and the background colour that pane contents
      # inherit. herdr's own theme is tokyo-night to match.
      theme = "TokyoNight Storm";

      # Applies to the theme background above. herdr's panels are painted with
      # "reset" so they inherit it instead of covering it.
      background-opacity = 0.9;
      background-blur = true;

      font-family = "0xProto Nerd Font";

      # Launch herdr instead of a shell. Reopening a window re-attaches to the
      # running server rather than starting fresh. There is no shell to fall
      # back to, so if herdr fails to start the window closes immediately.
      # The store path is required: ghostty runs this through
      # `bash --noprofile --norc`, and ghostty itself is started by launchd, so
      # the only PATH available is /usr/bin:/bin:/usr/sbin:/sbin.
      command = lib.getExe pkgs.herdr;

      # The command above is not a shell, and zsh injection would leak ghostty's
      # ZDOTDIR into the shells herdr spawns inside panes. Nothing is lost:
      # prompt marks and titles written in a pane stop at herdr anyway.
      shell-integration = "none";

      # Closing the window only detaches: the herdr server keeps the panes
      # running, so the prompt asks about nothing.
      confirm-close-surface = false;

      # herdr can bind alt chords, so option must arrive as alt rather than
      # composing into a special character.
      macos-option-as-alt = true;
    };
  };
}
