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
    enableGitIntegration = false;
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
      ".wt/"
    ];
    settings = {
      core = {
        # Status without stat-ing the whole worktree; the prompt runs one every
        # command (fetch_status in omp.toml). 70ms -> 20ms on a 12k-file tree.
        # Costs one daemon per worktree.
        fsmonitor = true;
        # Only pays off next to fsmonitor, which already skips the scan.
        untrackedCache = true;
      };
      # History walks read the commit-graph instead of parsing commits: 8x on a
      # 16k commit repo. Incremental on fetch, unlike `git maintenance start`,
      # which installs a launchd job.
      fetch.writeCommitGraph = true;
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
