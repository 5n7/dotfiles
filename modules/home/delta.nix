# Terminal diff viewer used as the git pager. https://github.com/dandavison/delta
{ ... }:
{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "GitHub Dark";
    };
  };
}
