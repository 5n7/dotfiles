# The complete OmniWM settings file.
let
  hotkey = id: binding: { inherit id binding; };
  unassigned = id: hotkey id "Unassigned";
  floatingRule = id: bundleId: {
    inherit bundleId id;
    layout = "float";
  };
  workspaceRule = id: bundleId: assignToWorkspace: {
    inherit assignToWorkspace bundleId id;
  };
  indices = count: builtins.genList (index: index) count;
  oneBased = count: map (index: index + 1) (indices count);
  directions = [
    "left"
    "right"
    "up"
    "down"
  ];
  unassignedIndexed =
    prefix: start: count:
    map (index: unassigned "${prefix}.${toString (index + start)}") (indices count);

  workspaces = [
    {
      id = "AD36F001-C57E-41A5-AC1D-DF5249D007F0";
      name = "1";
      displayName = "A";
      layoutType = "dwindle";
      monitorAssignment.type = "main";
    }
    {
      id = "454CECD4-5E9D-4ED1-95D7-979D48817F5F";
      name = "2";
      displayName = "B";
      layoutType = "niri";
      monitorAssignment.type = "main";
    }
    {
      id = "BEB842B5-E894-4791-9FD1-397C3CDD3538";
      name = "3";
      displayName = "N";
      layoutType = "dwindle";
      monitorAssignment.type = "main";
    }
    {
      id = "248AA883-2261-4D45-943C-79C0E46A232B";
      name = "4";
      displayName = "S";
      layoutType = "dwindle";
      monitorAssignment.type = "main";
    }
    {
      id = "8B8C45D6-CE9E-41D9-BD50-BE4989D5E3DE";
      name = "5";
      displayName = "T";
      layoutType = "dwindle";
      monitorAssignment.type = "main";
    }
    {
      id = "5953F2BF-A378-4266-91B2-287174C4FA4D";
      name = "6";
      displayName = "X";
      layoutType = "dwindle";
      monitorAssignment.type = "main";
    }
    {
      id = "A7D5E104-6985-4516-8ED5-07F144F2A33D";
      name = "7";
      displayName = "U";
      layoutType = "dwindle";
      monitorAssignment.type = "main";
    }
    {
      id = "0E18F6B0-345A-4078-8B21-33641F07A861";
      name = "8";
      displayName = "I";
      layoutType = "dwindle";
      monitorAssignment.type = "main";
    }
    {
      id = "8D4D711C-2B2F-4FEC-86BF-FA952037738A";
      name = "9";
      displayName = "O";
      layoutType = "dwindle";
      monitorAssignment.type = "secondary";
    }
  ];

  scratchpadHotkeys = builtins.concatLists (
    map (slot: [
      (unassigned "toggleScratchpad.${toString slot}")
      (unassigned "assignFocusedWindowToScratchpad.${toString slot}")
    ]) (oneBased 10)
  );

  workspaceHotkeys = builtins.concatLists (
    builtins.genList (
      index:
      let
        key = (builtins.elemAt workspaces index).displayName;
      in
      [
        (hotkey "switchWorkspace.${toString index}" "Option+${key}")
        (hotkey "moveToWorkspace.${toString index}" "Option+Shift+${key}")
      ]
    ) (builtins.length workspaces)
  );

  workspaceSlotHotkeys = builtins.concatLists (
    map (slot: [
      (unassigned "switchWorkspaceSlot.${toString slot}")
      (unassigned "moveToWorkspaceSlot.${toString slot}")
    ]) (oneBased 9)
  );

  focusColumnHotkeys = map (
    index: hotkey "focusColumn.${toString index}" "Control+Option+${toString (index + 1)}"
  ) (indices 9);
in
{
  schemaVersion = 5;

  appearance = {
    mode = "automatic";
    tabRailAppIcons = false;
  };

  borders = {
    enabled = true;
    width = 3.0;
    color = {
      alpha = 1.0;
      blue = 0.9686274509803922;
      green = 0.6352941176470588;
      red = 0.47843137254901963;
    };
  };

  clipboard = {
    historyEnabled = false;
    ignoredTypes = [ ];
    maxItemBytes = 8388608;
    maxItems = 200;
    maxTotalBytes = 67108864;
  };

  dwindle = {
    defaultSplitRatio = 1.0;
    moveToRootStable = true;
    singleWindowFit = "fill";
    smartSplit = false;
    splitWidthMultiplier = 1.0;
    useGlobalGaps = true;
  };

  focus = {
    crossesMonitorAtEdge = true;
    edgeNavigationInterval = 1.5;
    followsMouse = false;
    followsMouseOnlyFullyVisible = false;
    followsWindowToMonitor = true;
    lockModifier = "off";
    moveCrossesMonitorAtEdge = true;
    moveMouseToFocusedWindow = true;
    raiseOnMouseFocus = false;
  };

  gaps = {
    fullscreenUsesOuterGaps = true;
    size = 8.0;
    outer = {
      bottom = 8.0;
      left = 8.0;
      right = 8.0;
      top = 8.0;
    };
  };

  general = {
    animationSpeed = 1.0;
    animationsEnabled = true;
    defaultLayoutType = "dwindle";
    hotkeysEnabled = true;
    hyperKeyModifiers = "Control+Option+Shift+Command";
    ipcEnabled = true;
    preventSleepEnabled = false;
    systemHyperTrigger = "None";
    updateChecksEnabled = false;
    workspaceAutoBackAndForth = false;
  };

  gestures = {
    adoptNativeMoveAcrossDisplays = false;
    adoptNativeResize = false;
    dwindleGroupDragAcrossDisplays = "group";
    fingerCount = 3;
    invertDirection = true;
    mouseMoveModifierKey = "option";
    mouseResizeModifierKey = "option";
    mouseWheelSensitivity = 1.0;
    overviewGestureEnabled = false;
    overviewGestureFingerCount = 4;
    resizePreviewStyle = "live";
    scrollEnabled = true;
    scrollModifierKey = "optionShift";
    scrollSensitivity = 5.0;
    trackpadScrollStyle = "snap";
    windowGestureSensitivity = 1.0;
    windowMoveEnabled = false;
    windowMoveFingerCount = 4;
    windowResizeEnabled = false;
    windowResizeFingerCount = 3;
    workspaceSwipeAxis = "vertical";
    workspaceSwipeEdgeBehavior = "cycle";
    workspaceSwipeEnabled = false;
    workspaceSwipeFingerCount = 3;
  };

  hiddenBar = {
    enabled = false;
    hiddenBundleIDs = [ ];
    rehideIntervalSeconds = 5.0;
  };

  island.enabled = false;

  keyboardModes = { };

  launcher = {
    appFolders = [ ];
    cliFolders = [ ];
    entries = [ ];
    shell = "system";
    shellExecutable = "";
    terminal = "terminal";
  };

  mouseWarp = {
    constrainToArrangement = false;
    enabled = true;
    margin = 1;
  };

  niri = {
    allowOverscroll = false;
    alwaysCenterSingleColumn = false;
    centerFocusedColumn = "never";
    containerPrimarySpanPresets = [
      0.3333333333333333
      0.5
      0.6666666666666666
    ];
    defaultContainerPrimarySpan = 0.5;
    edgeGaps = true;
    infiniteLoop = true;
    moveWindowStacksIntoColumn = true;
    overscrollVisibleStripPercent = 5;
    resizeStepPercent = 5;
    singleWindowFit = "fill";
    visibleContainerCount = 2;
  };

  overview = {
    enabled = true;
    invertScrollDirection = false;
    matchFocusBorder = true;
    mouseScrollSpeed = 1.0;
    zoom = 1.0;
    backdrop = {
      alpha = 1.0;
      blue = 0.08;
      green = 0.05;
      red = 0.05;
    };
    windowBorders = {
      hovered = {
        alpha = 1.0;
        blue = 1.0;
        green = 0.6;
        red = 0.4;
      };
      normal = {
        alpha = 0.5;
        blue = 0.35;
        green = 0.3;
        red = 0.3;
      };
      selected = {
        alpha = 1.0;
        blue = 0.4;
        green = 0.8;
        red = 0.3;
      };
    };
  };

  quakeTerminal = {
    animationDuration = 0.2;
    autoHide = false;
    backgroundBlurRadius = 0;
    backgroundEffect = "standardBlur";
    enabled = false;
    heightPercent = 50.0;
    monitorMode = "focusedWindow";
    opacity = 1.0;
    position = "center";
    provider = "ghostty";
    widthPercent = 50.0;
  };

  routing = {
    mode = "custom";
    arrangements = [
      {
        id = "DD7F1799-C5E9-4169-933A-9DAD78C0472A";
        monitors = [
          {
            gridColumn = 0;
            gridRow = 0;
            monitorDisplayUUID = "37D8832A-2D66-02CA-B9F7-8F30A301B230";
            monitorName = "Built-in Retina Display";
          }
          {
            gridColumn = 1;
            gridRow = 0;
            monitorDisplayUUID = "B0DF8254-431C-49E5-B1CB-DEB25A61E736";
            monitorName = "LG ULTRAFINE";
          }
        ];
      }
    ];
  };

  scratchpads.labels = { };

  shellPermissions = {
    programs = [ ];
    widgets = [ ];
    services = {
      lyrics = true;
      weather = true;
    };
  };

  statusBar = {
    showAppNames = false;
    showIcon = true;
    showWorkspaceName = false;
    useWorkspaceId = false;
  };

  statusMenu = {
    hiddenControls = [ ];
    hiddenMenuItems = [ ];
    showControlHelp = true;
    showControls = true;
    showMenuItems = true;
  };

  windowSwitcher = {
    commandTab = "activeWorkspace";
    enabled = false;
    optionTab = "allWorkspaces";
    order = "omniLayout";
    scope = "allWorkspaces";
    showFooter = true;
  };

  workspaceBar = {
    autoHide = false;
    autoHideHideDelayMilliseconds = 0.0;
    autoHideRevealDelayMilliseconds = 0.0;
    backgroundOpacity = 0.1;
    deduplicateAppIcons = false;
    enabled = true;
    excludedBundleIDs = [ ];
    fullWidth = false;
    fullWidthNotchMode = "rightOfNotch";
    height = 22.0;
    hideEmptyWorkspaces = false;
    hideInNativeFullscreen = false;
    hoverPreviewsEnabled = true;
    iconOverrides = { };
    notchActiveZoneWidth = 180.0;
    notchMode = "moveBelowMenuBar";
    notificationBadgeRefreshIntervalSeconds = 5.0;
    notificationBadges = "off";
    position = "overlappingMenuBar";
    reserveLayoutSpace = false;
    revealHoldMilliseconds = 200.0;
    revealModifier = "off";
    showAccentHighlights = true;
    showFloatingWindows = false;
    showItemBackgrounds = true;
    showLabels = true;
    solidBlackBackground = false;
    systemStatsButton = false;
    transparentBackground = false;
    windowLevel = "popup";
    xOffset = 0.0;
    yOffset = 4.0;
  };

  appRules = [
    (floatingRule "A67FC070-F690-4FE9-9944-DA5C65B0DE72" "com.apple.ActivityMonitor")
    (floatingRule "4CE20B69-EC66-4442-88DD-F57BD610C4A0" "com.apple.systempreferences")

    (workspaceRule "4D31DD3A-C38C-4044-ACCB-762E980BB63C" "com.anthropic.claudefordesktop" "1")
    (workspaceRule "6A31F08A-4051-4354-B439-42F4C71894A3" "com.openai.codex" "1")
    (workspaceRule "486CEFA6-69AA-4A3C-AF27-BCD38F4F138B" "com.google.Chrome" "2")
    (workspaceRule "B6AD65C4-3419-4DD4-93B2-61266B602D9C" "notion.id" "3")
    (workspaceRule "CB2D767B-C322-4078-8593-B915566B1CE0" "com.tinyspeck.slackmacgap" "4")
    (workspaceRule "7876C9EF-437E-4D4F-9C27-B1B02F4AABCE" "com.mitchellh.ghostty" "5")
    (workspaceRule "2B3C8E57-0A99-4BAE-B78A-B0D36E97E016" "dev.herdr.app" "5")
    (workspaceRule "82B26BD2-9E20-4A2B-8A04-D30BD65D4486" "com.linear" "6")
    (workspaceRule "6A330142-968F-4D4F-9F51-3A014149ADC8" "com.citrolabs.ego.lite" "8")
  ];

  hotkeys =
    scratchpadHotkeys
    ++ workspaceHotkeys
    ++ workspaceSlotHotkeys
    ++ [
      (hotkey "workspaceBackAndForth" "Option+Tab")
      (unassigned "switchWorkspace.next")
      (unassigned "switchWorkspace.previous")
      (hotkey "focus.left" "Option+H")
      (hotkey "focus.down" "Option+J")
      (hotkey "focus.up" "Option+K")
      (hotkey "focus.right" "Option+L")
      (hotkey "focusPrevious" "Control+Option+Tab")
      (unassigned "focusDownOrLeft")
      (unassigned "focusUpOrRight")
      (unassigned "focusWindowTop")
      (unassigned "focusWindowBottom")
      (unassigned "focusWindowDownOrTop")
      (unassigned "focusWindowUpOrBottom")
      (unassigned "focusWindowOrWorkspaceDown")
      (unassigned "focusWindowOrWorkspaceUp")
      (unassigned "centerColumn")
      (unassigned "centerVisibleColumns")
      (hotkey "moveWindowToWorkspaceUp" "Control+Option+Shift+Up Arrow")
      (hotkey "moveWindowToWorkspaceDown" "Control+Option+Shift+Down Arrow")
      (hotkey "moveColumnToWorkspaceUp" "Control+Option+Shift+Page Up")
      (hotkey "moveColumnToWorkspaceDown" "Control+Option+Shift+Page Down")
    ]
    ++ unassignedIndexed "moveColumnToWorkspace" 0 9
    ++ [
      (hotkey "move.left" "Option+Shift+H")
      (hotkey "move.down" "Option+Shift+J")
      (hotkey "move.up" "Option+Shift+K")
      (hotkey "move.right" "Option+Shift+L")
      (unassigned "moveWindowDown")
      (unassigned "moveWindowUp")
      (unassigned "moveWindowDownOrToWorkspaceDown")
      (unassigned "moveWindowUpOrToWorkspaceUp")
      (unassigned "consumeWindowIntoColumn")
      (unassigned "expelWindowFromColumn")
      (hotkey "focusMonitorNext" "Control+Command+Tab")
      (unassigned "focusMonitorPrevious")
      (hotkey "focusMonitorLast" "Control+Command+Grave")
    ]
    ++ map (direction: unassigned "moveWorkspaceToMonitor.${direction}") directions
    ++ map (direction: unassigned "moveWindowToMonitor.${direction}") directions
    ++ [
      (hotkey "toggleFullscreen" "Option+F")
      (unassigned "toggleNativeFullscreen")
      (hotkey "moveColumn.left" "Control+Option+Shift+Left Arrow")
      (hotkey "moveColumn.right" "Control+Option+Shift+Right Arrow")
      (unassigned "moveColumn.up")
      (unassigned "moveColumn.down")
      (hotkey "moveColumnToFirst" "Control+Option+Home")
      (hotkey "moveColumnToLast" "Control+Option+End")
      (hotkey "toggleColumnTabbed" "Control+Option+T")
      (hotkey "focusColumnFirst" "Option+Home")
      (hotkey "focusColumnLast" "Option+End")
    ]
    ++ focusColumnHotkeys
    ++ unassignedIndexed "focusWindowInColumn" 1 9
    ++ unassignedIndexed "moveColumnToIndex" 1 9
    ++ [
      (hotkey "cycleSizeForward" "Option+Period")
      (hotkey "cycleSizeBackward" "Control+Option+Comma")
      (unassigned "cycleWindowPrimarySpanForward")
      (unassigned "cycleWindowPrimarySpanBackward")
      (unassigned "cycleWindowSecondarySpanForward")
      (unassigned "cycleWindowSecondarySpanBackward")
      (hotkey "toggleContainerFullPrimarySpan" "Control+Option+Shift+F")
      (hotkey "expandContainerToAvailablePrimarySpan" "Control+Option+F")
      (hotkey "resetWindowSecondarySpan" "Control+Option+R")
      (hotkey "resizeContainerPrimarySpan.shrink" "Control+Option+Minus")
      (hotkey "resizeContainerPrimarySpan.grow" "Control+Option+Equal")
      (unassigned "resizeWindowPrimarySpan.shrink")
      (unassigned "resizeWindowPrimarySpan.grow")
      (hotkey "resizeWindowSecondarySpan.shrink" "Option+Shift+Minus")
      (hotkey "resizeWindowSecondarySpan.grow" "Option+Shift+Equal")
      (hotkey "balanceSizes" "Control+Option+B")
      (unassigned "moveToRoot")
      (unassigned "toggleSplit")
      (unassigned "swapSplit")
      (unassigned "resizeGrow.horizontal")
      (unassigned "resizeGrow.vertical")
      (unassigned "resizeShrink.horizontal")
      (unassigned "resizeShrink.vertical")
      (hotkey "resizeFocusedWindow.grow" "Option+Equal")
      (hotkey "resizeFocusedWindow.shrink" "Option+Minus")
      (unassigned "preselect.left")
      (unassigned "preselect.right")
      (unassigned "preselect.up")
      (unassigned "preselect.down")
      (unassigned "preselectClear")
      (unassigned "volumeUp")
      (unassigned "volumeDown")
      (unassigned "volumeMute")
      (unassigned "mediaPlayPause")
      (unassigned "mediaNext")
      (unassigned "mediaPrevious")
      (unassigned "toggleShortcutPause")
      (unassigned "beginPrefix")
      (unassigned "toggleWindowMode")
      (unassigned "exitKeyboardMode")
      (unassigned "openShellApp.example")
      (unassigned "newShellAppWindow.example")
      (hotkey "openCommandPalette" "Control+Option+Space")
    ]
    ++ map (mode: unassigned "openCommandPalette.${mode}") [
      "windows"
      "menu"
      "clipboard"
      "commands"
      "applications"
      "files"
    ]
    ++ [
      (hotkey "raiseAllFloatingWindows" "Option+Shift+R")
      (unassigned "toggleFloatingFocus")
      (unassigned "rescueOffscreenWindows")
      (hotkey "toggleFocusedWindowFloating" "Option+Shift+F")
      (unassigned "closeFocusedWindow") # Option+Q opens Vicinae's snippets instead.
      (hotkey "openMenuAnywhere" "Control+Option+M")
      (unassigned "setWindowMark")
      (unassigned "removeWindowMark")
      (unassigned "toggleWorkspaceBarVisibility")
      (unassigned "toggleHiddenBarPanel")
      (unassigned "toggleQuakeTerminal")
      (hotkey "toggleWorkspaceLayout" "Option+Comma")
      (hotkey "toggleOverview" "Control+Option+O")
      (unassigned "toggleSystemStats")
    ]
    ++ map (widget: unassigned "toggleShellWidget.${widget}") [
      "battery-details"
      "clock"
      "control-center"
      "hidden-bar"
      "media"
      "notifications"
      "system-stats"
      "volume"
      "wifi"
      "workspaces"
    ];

  inherit workspaces;
}
