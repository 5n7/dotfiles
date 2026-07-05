# Git and related tooling (delta, gh, gitui).
{
  host,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.gh = {
    enable = true;
    extensions = [ pkgs-unstable.gh-poi ];
    settings.aliases.co = "pr checkout";
  };

  programs.git = {
    enable = true;
    ignores = [
      ".claude/projects/"
      ".claude/scheduled_tasks.lock"
      ".claude/settings.local.json"
      ".claude/worktrees"
      ".cursor/"
      ".DS_Store"
      ".serena/"
      ".vscode/"
    ];
    settings = {
      delta.navigate = true;
      init.defaultBranch = "main";
      merge.conflictStyle = "zdiff3";
      user = {
        name = "Shunta Komatsu";
        email = host.email;
      }
      // lib.optionalAttrs (host.signingKey != null) {
        signingkey = host.signingKey;
      };
      wt = {
        copyignored = true;
        hook = [
          "aqua policy allow"
          "mise trust"
        ];
      };
    }
    // lib.optionalAttrs (host.signingKey != null) {
      commit.gpgsign = true;
      tag.gpgsign = true;
      gpg.program = "${pkgs.gnupg}/bin/gpg";
    };
  };

  programs.gitui = {
    enable = true;
    theme = builtins.readFile ../../.config/gitui/theme.ron;
  };
}
