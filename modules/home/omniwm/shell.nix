# OmniShell overrides, layered over the bundled Default style in shell/default/.
settings: {
  profile = "default";

  profiles.default = {
    leading = [ "workspaces" ];
    center = [ ];
    trailing = [ ];

    # Default's own [workspaceBar] wins over settings.toml, so restate the bar here.
    workspaceBar = {
      inherit (settings.workspaceBar)
        backgroundOpacity
        fullWidth
        height
        position
        reserveLayoutSpace
        showAccentHighlights
        showItemBackgrounds
        showLabels
        solidBlackBackground
        systemStatsButton
        transparentBackground
        xOffset
        yOffset
        ;
    };
  };
}
