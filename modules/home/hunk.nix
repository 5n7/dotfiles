# Terminal diff viewer used as the git pager. https://github.com/modem-dev/hunk
{ ... }:
{
  programs.hunk = {
    enable = true;
    enableGitIntegration = true;
    settings = {
      line_numbers = true;
      mode = "split";
      theme = "graphite";
    };
  };
}
