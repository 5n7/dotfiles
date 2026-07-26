# Terminal diff viewer used as the git pager. https://github.com/modem-dev/hunk
{ ... }:
{
  programs.hunk = {
    enable = true;
    enableGitIntegration = true;
    settings = {
      agent_notes = true;
      line_numbers = true;
      mode = "split";
      theme = "github-dark-default";
      watch = true;
    };
  };
}
