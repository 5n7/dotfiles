# macOS system defaults, fonts, and services.
{
  pkgs,
  ...
}:
let
  # Control + Option (NSControlKeyMask | NSAlternateKeyMask).
  ctrlOpt = 786432;
in
{
  system.defaults = {
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

    trackpad.Clicking = true;

    # Show battery percentage in the menu bar.
    controlcenter.BatteryShowPercentage = true;

    # Show seconds in the menu bar clock.
    menuExtraClock.ShowSeconds = true;

    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      # Use F1-F12 as standard function keys (not media keys); press fn for media.
      "com.apple.keyboard.fnState" = true;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      # Don't turn straight quotes into curly "smart" quotes — breaks code/Markdown.
      NSAutomaticQuoteSubstitutionEnabled = false;
      "com.apple.trackpad.scaling" = 2.0;
    };

    CustomUserPreferences = {
      # Apple Japanese IME (Kotoeri) — engineer-friendly defaults. Keys captured
      # from the live `com.apple.inputmethod.Kotoeri` domain after toggling them in
      # System Settings, so they match this macOS version's actual pref names.
      "com.apple.inputmethod.Kotoeri" = {
        JIMPrefLiveConversionKey = 0; # disable live conversion (勝手に変換しない)
        JIMPrefCharacterForYenKey = 1; # ¥ key inputs backslash (\) instead of ¥
        JIMPrefFullWidthNumeralCharactersKey = 0; # numerals are half-width
        JIMPrefAutocorrectionKey = 0; # disable IME autocorrection
      };

      "com.knollsoft.Rectangle" = {
        launchOnLogin = 1;
        gapSize = 10;

        leftHalf = {
          keyCode = 4; # H
          modifierFlags = ctrlOpt;
        };
        rightHalf = {
          keyCode = 37; # L
          modifierFlags = ctrlOpt;
        };
        topHalf = {
          keyCode = 40; # K
          modifierFlags = ctrlOpt;
        };
        bottomHalf = {
          keyCode = 38; # J
          modifierFlags = ctrlOpt;
        };
        maximize = {
          keyCode = 36; # Return
          modifierFlags = ctrlOpt;
        };
      };
    };
  };

  fonts.packages = [ pkgs.nerd-fonts._0xproto ];

  services.tailscale.enable = true;
}
