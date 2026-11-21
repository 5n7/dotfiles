# ghostty launches herdr directly, so it is a single-surface host: herdr owns
# tabs, splits, scrollback, mouse, and the window title. herdr emulates each
# pane's terminal, so ghostty's equivalents never see those escape sequences.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    # nixpkgs' ghostty is Linux-only, so the cask stays and Nix manages only
    # the config file.
    package = null;
    # Shell integration is off below, so HM's manual `source` block would inject
    # what ghostty is being told not to.
    enableZshIntegration = false;
    # Grouped by concern (appearance, what the window runs, input) rather than
    # sorted, so a comment can refer to the line above it.
    settings = {
      # Pane contents inherit this palette and background. herdr's theme is
      # tokyo-night to match.
      theme = "TokyoNight Storm";

      # Applies to the theme background above. herdr's panels are painted with
      # "reset" so they inherit it instead of covering it.
      background-opacity = 0.9;
      background-blur = true;

      # 0xProto has no CJK, and without an explicit fallback CoreText often
      # picks a mincho face for Japanese. Bare "Hiragino Sans" resolves to W3,
      # lighter than 0xProto Regular; W4 shares its CoreText weight class (5).
      font-family = [
        "0xProto Nerd Font"
        "Hiragino Sans W4"
      ];
      # W7 matches 0xProto Bold's weight class (9); W4 would stay thin when bold.
      font-family-bold = [
        "0xProto Nerd Font"
        "Hiragino Sans W7"
      ];

      # herdr draws its own status line, so the titlebar only shows a title
      # nothing sets. "hidden" keeps the native frame and rounded corners that
      # `window-decoration = none` would strip. It loses the window buttons and
      # titlebar dragging, but OmniWM tiles and moves windows by keyboard.
      macos-titlebar-style = "hidden";

      # "top,bottom" in points. Without a titlebar the first row sits flush
      # against the window edge, so the top gets more room than the default 2.
      window-padding-y = "8,2";

      # Reopening a window re-attaches to the running server. With no shell to
      # fall back to, the window closes at once if herdr fails to start. The
      # store path is required: launchd starts ghostty, which runs this through
      # `bash --noprofile --norc`, so PATH is only /usr/bin:/bin:/usr/sbin:/sbin.
      command = lib.getExe pkgs.herdr;

      # herdr server never loads sessionVariables; prefix+e uses EDITOR.
      env = [
        "EDITOR=${lib.getExe config.programs.neovim.finalPackage}"
        "VISUAL=${lib.getExe config.programs.neovim.finalPackage}"
      ];

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
