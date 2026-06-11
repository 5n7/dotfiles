# Terminal emulator (ghostty) and multiplexer (cmux) configuration.
{ ... }:
{
  # cmux config, serialized to JSON from a Nix attrset.
  xdg.configFile."cmux/cmux.json".text = builtins.toJSON {
    actions = {
      claude = {
        type = "agent";
        command = "claude";
      };
      dev = {
        type = "workspaceCommand";
        command = "dev";
      };
      "new-terminal" = {
        type = "builtin";
        action = "cmux.newTerminal";
      };
    };
    commands = {
      dev = {
        layout = {
          direction = "horizontal";
          ratio = 0.7;
          surfaces = [
            { type = "terminal"; }
            {
              type = "terminal";
              command = "claude";
            }
          ];
        };
      };
    };
    ui = {
      surfaceTabBar = {
        buttons = [
          "new-terminal"
          "claude"
          "dev"
        ];
      };
    };
  };

  programs.ghostty = {
    enable = true;
    # ghostty is installed via Homebrew cask, so do not pull the nixpkgs
    # package; only manage the config file.
    package = null;
    # ghostty injects shell integration automatically via the
    # `shell-integration = "zsh"` setting below, so HM's manual `source` block
    # is redundant. It also breaks under cmux, which sets GHOSTTY_RESOURCES_DIR
    # to a bundle that ships no shell-integration scripts.
    enableZshIntegration = false;
    settings = {
      copy-on-select = "clipboard";
      # Repeated keys are expressed as lists (listsAsDuplicateKeys).
      font-codepoint-map = [
        "U+3000-U+303F=Hiragino Sans W4"
        "U+3040-U+309F=Hiragino Sans W4"
        "U+30A0-U+30FF=Hiragino Sans W4"
        "U+3400-U+4DBF=Hiragino Sans W4"
        "U+4E00-U+9FFF=Hiragino Sans W4"
        "U+F900-U+FAFF=Hiragino Sans W4"
        "U+FF00-U+FFEF=Hiragino Sans W4"
      ];
      font-family = "0xProto Nerd Font";
      font-size = 13;
      keybind = [
        "alt+h=goto_split:left"
        "alt+j=goto_split:down"
        "alt+k=goto_split:up"
        "alt+l=goto_split:right"
      ];
      macos-option-as-alt = true;
      macos-titlebar-style = "tabs";
      notify-on-command-finish = "always";
      notify-on-command-finish-action = "notify";
      notify-on-command-finish-after = "10s";
      scrollback-limit = 100000;
      shell-integration = "zsh";
      shell-integration-features = "cursor,sudo,title";
      split-inherit-working-directory = true;
      tab-inherit-working-directory = true;
      theme = "TokyoNight Storm";
      unfocused-split-opacity = "0.8";
      window-inherit-working-directory = true;
      window-padding-x = 8;
      window-padding-y = 4;
      window-save-state = "always";
      working-directory = "~/src";
    };
  };
}
