# Git and related tooling (gh, gitui).
{
  host,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  programs.gh = {
    enable = true;
    extensions = [
      pkgs-unstable.gh-poi
      pkgs-unstable.gh-stack
    ];
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
    settings = lib.mkMerge [
      {
        core = {
          # Status without stat-ing the whole worktree; the prompt runs one every
          # command (fetch_status in omp.toml). 70ms -> 20ms on a 12k-file tree.
          # Costs one daemon per worktree.
          fsmonitor = true;
          # With fsmonitor, also skips scanning the worktree for new files.
          untrackedCache = true;
        };
        # History walks read the commit-graph instead of parsing commits: 8x on a
        # 16k commit repo. Written on fetch, so `git maintenance start` and its
        # launchd job aren't needed.
        fetch.writeCommitGraph = true;
        init.defaultBranch = "main";
        merge.conflictStyle = "zdiff3";
        user = {
          name = "Shunta Komatsu";
          inherit (host) email;
        };
        wt = {
          copyignored = true;
          hook = [
            "aqua policy allow"
            "mise trust"
          ];
        };
      }
      (lib.mkIf (host.signingKey != null) {
        commit.gpgsign = true;
        gpg.program = "${pkgs.gnupg}/bin/gpg";
        tag.gpgsign = true;
        user.signingkey = host.signingKey;
      })
    ];
  };

  programs.gitui = {
    enable = true;
    theme = builtins.readFile ../../.config/gitui/theme.ron;
  };
}
