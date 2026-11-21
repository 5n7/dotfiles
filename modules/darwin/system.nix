# macOS system defaults, fonts, and services.
{
  pkgs,
  ...
}:
{
  system.defaults = {
    controlcenter.BatteryShowPercentage = true;

    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 48;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
    };

    menuExtraClock.ShowSeconds = true;

    # OmniWM requires separate spaces and supports native fullscreen there.
    # Changes take effect after a logout.
    spaces.spans-displays = false;

    trackpad.Clicking = true;

    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      # F1-F12 act as function keys; fn gives the media keys.
      "com.apple.keyboard.fnState" = true;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      # Curly quotes break code and Markdown.
      NSAutomaticQuoteSubstitutionEnabled = false;
      "com.apple.trackpad.scaling" = 2.0;
    };

    CustomUserPreferences = {
      # Apple's Japanese IME. The key names were read from this domain after
      # toggling each option in System Settings.
      "com.apple.inputmethod.Kotoeri" = {
        JIMPrefAutocorrectionKey = 0;
        JIMPrefCharacterForYenKey = 1; # The ¥ key types a backslash.
        JIMPrefFullWidthNumeralCharactersKey = 0;
        JIMPrefLiveConversionKey = 0;
      };
    };
  };

  fonts.packages = [ pkgs.nerd-fonts._0xproto ];
}
