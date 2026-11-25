# The app's main layout without the sidebar's brand and footer, and with no
# window drag areas since OmniWM places the window. The window buttons are moved
# off screen.
{
  id = "root";
  type = "row";
  titlebar = "none";
  traffic_lights = [
    (-100)
    (-100)
  ];
  background = "canvas";
  terminal_padding = [
    14
    12
  ];
  divider = {
    width = 1;
    color = "border";
  };
  children = [
    {
      id = "sidebar";
      type = "column";
      size.px = 268;
      min = 44;
      max = 480;
      background = "chrome";
      resizable = false;
      children = [
        {
          id = "sidebar-lists";
          type = "column";
          padding = [
            12
            0
          ];
          children = [
            {
              id = "spaces";
              type = "block";
              size.weight = 1;
              min = 90;
              content.mod = "spaces";
            }
            {
              id = "agents";
              type = "block";
              size.weight = 1;
              min = 90;
              content.mod = "agents";
            }
          ];
        }
        {
          id = "gcloud";
          type = "block";
          size.px = 39;
          content.mod = "gcloud";
        }
        {
          id = "usage";
          type = "block";
          size.px = 40;
          content.mod = "usage";
        }
      ];
    }
    {
      id = "work";
      type = "column";
      resizable = false;
      children = [
        {
          id = "tabs";
          type = "block";
          size.px = 42;
          content.mod = "tabs";
        }
        {
          id = "work-body";
          type = "row";
          padding = 8;
          gap = 8;
          children = [
            {
              id = "main";
              type = "block";
              content = {
                tab = "active";
                pane = {
                  gap = 8;
                  radius = 10;
                  background = "background";
                  lone = true;
                  border = {
                    width = 1;
                    color = "border";
                  };
                  focus = {
                    width = 1;
                    color = "accent";
                  };
                };
              };
            }
            # The Files and Changes panels, opened from the tab bar.
            {
              id = "panel";
              type = "column";
              hidden = true;
              size.px = 368;
              min = 280;
              max = 900;
              children = [
                {
                  id = "panel-body";
                  type = "stack";
                  active = "files";
                  children = [
                    {
                      id = "files";
                      type = "block";
                      content.mod = "files";
                    }
                    {
                      id = "changes";
                      type = "block";
                      content.mod = "changes";
                    }
                  ];
                }
              ];
            }
          ];
        }
        {
          id = "status";
          type = "block";
          size.px = 28;
          content.mod = "workspace-status";
        }
      ];
    }
  ];
}
