# Complete hardware-neutral OmniWM configuration.
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

  workspace = id: name: displayName: layoutType: monitorType: {
    inherit
      displayName
      id
      layoutType
      name
      ;
    monitorAssignment.type = monitorType;
  };
  workspaceSpecs = [
    {
      id = "AD36F001-C57E-41A5-AC1D-DF5249D007F0";
      name = "1";
      displayName = "A";
      layoutType = "dwindle";
      monitorType = "main";
    }
    {
      id = "454CECD4-5E9D-4ED1-95D7-979D48817F5F";
      name = "2";
      displayName = "B";
      layoutType = "dwindle";
      monitorType = "main";
    }
    {
      id = "BEB842B5-E894-4791-9FD1-397C3CDD3538";
      name = "3";
      displayName = "N";
      layoutType = "dwindle";
      monitorType = "main";
    }
    {
      id = "248AA883-2261-4D45-943C-79C0E46A232B";
      name = "4";
      displayName = "S";
      layoutType = "dwindle";
      monitorType = "main";
    }
    {
      id = "8B8C45D6-CE9E-41D9-BD50-BE4989D5E3DE";
      name = "5";
      displayName = "T";
      layoutType = "dwindle";
      monitorType = "main";
    }
    {
      id = "5953F2BF-A378-4266-91B2-287174C4FA4D";
      name = "6";
      displayName = "X";
      layoutType = "dwindle";
      monitorType = "main";
    }
    {
      id = "A7D5E104-6985-4516-8ED5-07F144F2A33D";
      name = "7";
      displayName = "U";
      layoutType = "dwindle";
      monitorType = "main";
    }
    {
      id = "0E18F6B0-345A-4078-8B21-33641F07A861";
      name = "8";
      displayName = "I";
      layoutType = "dwindle";
      monitorType = "main";
    }
    {
      id = "8D4D711C-2B2F-4FEC-86BF-FA952037738A";
      name = "9";
      displayName = "O";
      layoutType = "dwindle";
      monitorType = "secondary";
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
        key = (builtins.elemAt workspaceSpecs index).displayName;
      in
      [
        (hotkey "switchWorkspace.${toString index}" "Option+${key}")
        (hotkey "moveToWorkspace.${toString index}" "Option+Shift+${key}")
      ]
    ) (builtins.length workspaceSpecs)
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
  schemaVersion = 2;

  monitorBarOverrides = [ ];
  monitorDwindleOverrides = [ ];
  monitorGapOverrides = [ ];
  monitorNiriOverrides = [ ];
  monitorOrientationOverrides = [ ];
  monitorRoutingOverrides = [
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

  appearance.mode = "automatic";

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
    followsMouse = false;
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
    animationsEnabled = true;
    defaultLayoutType = "dwindle";
    hotkeysEnabled = true;
    hyperKeyModifiers = "Control+Option+Shift+Command";
    ipcEnabled = true;
    preventSleepEnabled = false;
    systemHyperTrigger = "None";
    updateChecksEnabled = false;
  };

  gestures = {
    fingerCount = 3;
    invertDirection = true;
    mouseMoveModifierKey = "option";
    mouseResizeModifierKey = "option";
    scrollEnabled = true;
    scrollModifierKey = "optionShift";
    scrollSensitivity = 5.0;
    trackpadScrollStyle = "snap";
    workspaceSwipeAxis = "vertical";
    workspaceSwipeEnabled = false;
    workspaceSwipeFingerCount = 3;
  };

  hiddenBar = {
    enabled = false;
    hiddenBundleIDs = [ ];
    rehideIntervalSeconds = 5.0;
  };

  mouseWarp = {
    constrainToArrangement = false;
    enabled = true;
    margin = 1;
  };

  niri = {
    alwaysCenterSingleColumn = false;
    centerFocusedColumn = "never";
    containerPrimarySpanPresets = [
      0.3333333333333333
      0.5
      0.6666666666666666
    ];
    defaultContainerPrimarySpan = 0.5;
    infiniteLoop = false;
    singleWindowFit = "fill";
    visibleContainerCount = 2;
  };

  overview = {
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
    widthPercent = 50.0;
  };

  routing.mode = "custom";

  scratchpads.labels = { };

  statusBar = {
    showAppNames = false;
    showWorkspaceName = false;
    useWorkspaceId = false;
  };

  workspaceBar = {
    backgroundOpacity = 0.1;
    deduplicateAppIcons = false;
    enabled = true;
    excludedBundleIDs = [ ];
    height = 22.0;
    hideEmptyWorkspaces = false;
    hideInNativeFullscreen = false;
    iconOverrides = { };
    notchActiveZoneWidth = 180.0;
    notchMode = "moveBelowMenuBar";
    position = "overlappingMenuBar";
    reserveLayoutSpace = false;
    revealHoldMilliseconds = 200.0;
    revealModifier = "off";
    showFloatingWindows = false;
    showLabels = true;
    systemStatsButton = false;
    windowLevel = "popup";
    xOffset = 0.0;
    yOffset = 4.0;
  };

  appRules = [
    # Floating windows.
    (floatingRule "A67FC070-F690-4FE9-9944-DA5C65B0DE72" "com.apple.ActivityMonitor")
    (floatingRule "4CE20B69-EC66-4442-88DD-F57BD610C4A0" "com.apple.systempreferences")

    # Workspace-assigned apps.
    (workspaceRule "4D31DD3A-C38C-4044-ACCB-762E980BB63C" "com.anthropic.claudefordesktop" "1")
    (workspaceRule "6A31F08A-4051-4354-B439-42F4C71894A3" "com.openai.codex" "1")
    (workspaceRule "486CEFA6-69AA-4A3C-AF27-BCD38F4F138B" "com.google.Chrome" "2")
    (workspaceRule "C21156B1-0224-4998-97E3-8F4FA65B9F3B" "company.thebrowser.dia" "2")
    (workspaceRule "B6AD65C4-3419-4DD4-93B2-61266B602D9C" "notion.id" "3")
    (workspaceRule "CB2D767B-C322-4078-8593-B915566B1CE0" "com.tinyspeck.slackmacgap" "4")
    (workspaceRule "7876C9EF-437E-4D4F-9C27-B1B02F4AABCE" "com.mitchellh.ghostty" "5")
    (workspaceRule "82B26BD2-9E20-4A2B-8A04-D30BD65D4486" "com.linear" "6")
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
      (hotkey "setContainerPrimarySpan.decrease10Percent" "Control+Option+Minus")
      (hotkey "setContainerPrimarySpan.increase10Percent" "Control+Option+Equal")
      (unassigned "setWindowPrimarySpan.decrease10Percent")
      (unassigned "setWindowPrimarySpan.increase10Percent")
      (hotkey "setWindowSecondarySpan.decrease10Percent" "Option+Shift+Minus")
      (hotkey "setWindowSecondarySpan.increase10Percent" "Option+Shift+Equal")
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
      (hotkey "openCommandPalette" "Control+Option+Space")
      (hotkey "raiseAllFloatingWindows" "Option+Shift+R")
      (unassigned "rescueOffscreenWindows")
      (hotkey "toggleFocusedWindowFloating" "Option+Shift+F")
      (hotkey "closeFocusedWindow" "Option+Q")
      (hotkey "openMenuAnywhere" "Control+Option+M")
      (unassigned "toggleWorkspaceBarVisibility")
      (unassigned "toggleHiddenBarPanel")
      (unassigned "toggleQuakeTerminal")
      (hotkey "toggleWorkspaceLayout" "Option+Comma")
      (hotkey "toggleOverview" "Control+Option+O")
      (unassigned "toggleSystemStats")
    ];

  workspaces = map (
    specification:
    workspace specification.id specification.name specification.displayName specification.layoutType
      specification.monitorType
  ) workspaceSpecs;
}
