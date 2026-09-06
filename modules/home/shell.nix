# Shell (zsh) and prompt/completion tooling.
{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  programs.direnv = {
    enable = true;
    enableZshIntegration = false;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    # Pre-rendered via home.activation and sourced from ./zsh/fzf.zsh.
    enableZshIntegration = false;
  };

  programs.oh-my-posh = {
    enable = true;
    # 26.05 is 29.14.0; concurrent cache writes can drop the theme.
    package = pkgs-unstable.oh-my-posh;
    # Pre-rendered via home.activation and sourced from ./zsh/omp.zsh.
    enableZshIntegration = false;
    settings = builtins.fromTOML (builtins.readFile ./omp.toml);
  };

  # Fallback when the shared session cache has no CONFIG.
  home.sessionVariables.POSH_CONFIG = "${config.xdg.configHome}/oh-my-posh/config.json";

  programs.sheldon = {
    enable = true;
    # Injected via ./zsh/sheldon.zsh instead of HM's deprecated initExtra path.
    enableZshIntegration = false;
    settings = {
      plugins = {
        # `0-` so zsh-defer loads before plugins that use the defer template.
        "0-zsh-defer" = {
          github = "romkatv/zsh-defer";
        };
        fast-syntax-highlighting = {
          apply = [ "defer" ];
          github = "zdharma-continuum/fast-syntax-highlighting";
        };
        fzf-tab = {
          apply = [ "defer" ];
          github = "Aloxaf/fzf-tab";
        };
        zsh-abbr = {
          apply = [ "defer" ];
          github = "olets/zsh-abbr";
        };
        zsh-autosuggestions = {
          apply = [ "defer" ];
          github = "zsh-users/zsh-autosuggestions";
        };
      };
      shell = "zsh";
      templates = {
        defer = "{% for file in files %}zsh-defer source \"{{ file }}\"\n{% endfor %}";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.zsh = {
    enable = true;
    # Own daily-cached compinit in ./zsh/compinit.zsh; HM's runs a full audit
    # every shell.
    enableCompletion = false;
    dotDir = "${config.xdg.configHome}/zsh";

    envExtra = ''
      [[ -f "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"
    '';

    history = {
      append = true;
      expireDuplicatesFirst = true;
      extended = true;
      findNoDups = true;
      ignoreAllDups = true;
      ignoreDups = true;
      ignoreSpace = true;
      path = "$HOME/.local/state/zsh/history";
      save = 1000000;
      share = true;
      size = 100000;
    };

    initContent = lib.concatMapStringsSep "\n" builtins.readFile [
      ./zsh/options.zsh
      ./zsh/fpath.zsh
      ./zsh/compinit.zsh
      ./zsh/sheldon.zsh
      ./zsh/env-cache.zsh
      ./zsh/functions.zsh
      ./zsh/fzf.zsh
      ./zsh/homebrew.zsh
      ./zsh/keymaps.zsh
      ./zsh/omp.zsh
      ./zsh/deferred.zsh
    ];

    shellAliases = {
      cp = "cp -ir";
      mkdir = "mkdir -p";
      mv = "mv -i";
      rm = "gomi";
    };
  };

  # No-op when the lockfile already matches; only hits the network on fresh
  # setup or plugin list changes. Refresh upstream with `sheldon lock --update`.
  home.activation.sheldonLock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${config.programs.sheldon.package}/bin/sheldon lock
  '';

  # Pre-render init scripts (+ zcompile) so interactive shells only `source`
  # a cache file instead of spawning subprocesses + eval.
  home.activation.precomputeShellInit = lib.hm.dag.entryAfter [ "sheldonLock" ] ''
    cache_shell_init() {
      local cache_file="$1"
      shift
      run ${pkgs.bash}/bin/bash ${./cache-shell-init.sh} \
        ${config.programs.zsh.package}/bin/zsh "${config.xdg.cacheHome}/$cache_file" "$@"
    }
    cache_shell_init direnv/hook.zsh ${config.programs.direnv.package}/bin/direnv hook zsh
    cache_shell_init fzf/init.zsh ${config.programs.fzf.package}/bin/fzf --zsh
    cache_shell_init git-wt/init.zsh ${pkgs-unstable.git-wt}/bin/git-wt --init zsh
    cache_shell_init mise/activate.zsh ${config.programs.mise.package}/bin/mise activate zsh
    cache_shell_init oh-my-posh/init.zsh ${config.programs.oh-my-posh.package}/bin/oh-my-posh init zsh \
      --config ${config.xdg.configHome}/oh-my-posh/config.json
    cache_shell_init sheldon/source.zsh ${config.programs.sheldon.package}/bin/sheldon source
    cache_shell_init zoxide/init.zsh ${config.programs.zoxide.package}/bin/zoxide init zsh
    unset -f cache_shell_init
  '';

  # zcompile the generated rc files; parsing .zshrc is ~12ms. The .zwc lands in
  # the writable ZDOTDIR while the rc file is a store symlink with an epoch
  # mtime, so zsh's staleness check never fires: it must be rebuilt every switch.
  home.activation.zcompileZshrc = lib.hm.dag.entryAfter [ "precomputeShellInit" ] ''
    run ${config.programs.zsh.package}/bin/zsh -c \
      'zcompile -R ${config.programs.zsh.dotDir}/.zshenv
       zcompile -R ${config.programs.zsh.dotDir}/.zshrc'
  '';

  xdg.configFile."zsh-abbr/user-abbreviations".source = ../../.config/zsh-abbr/user-abbreviations;
}
