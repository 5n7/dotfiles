# The app's main layout without the sidebar's brand and footer. An empty strip
# under the window buttons, which drags the window, takes the brand's place, and
# the usage mod, sized to fit, sits at the sidebar's foot.
{
  id = "root";
  type = "row";
  titlebar = "none";
  traffic_lights = [
    12
    16
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
        # A block needs content, so the strip is a row with none.
        {
          id = "titlebar";
          type = "row";
          size.px = 36;
          window_drag = true;
          children = [ ];
        }
        {
          id = "sidebar-lists";
          type = "column";
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
          window_drag = true;
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
                  header = {
                    content.mod = "pane";
                    height = 30;
                    position = "top";
                    reveal = "always";
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
