# Shell (zsh) and prompt/completion tooling.
{
  config,
  lib,
  pkgs-unstable,
  ...
}:
{
  programs.direnv = {
    enable = true;
    enableZshIntegration = false;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;

  programs.oh-my-posh = {
    enable = true;
    # Pre-rendered via home.activation and sourced from ./zsh/omp.zsh.
    enableZshIntegration = false;
    settings = builtins.fromTOML (builtins.readFile ./omp.toml);
  };

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
      ./zsh/functions.zsh
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
    run mkdir -p \
      ${config.xdg.cacheHome}/direnv \
      ${config.xdg.cacheHome}/git-wt \
      ${config.xdg.cacheHome}/mise \
      ${config.xdg.cacheHome}/oh-my-posh \
      ${config.xdg.cacheHome}/sheldon \
      ${config.xdg.cacheHome}/zoxide
    run ${config.programs.direnv.package}/bin/direnv hook zsh \
      > ${config.xdg.cacheHome}/direnv/hook.zsh
    run ${pkgs-unstable.git-wt}/bin/git-wt --init zsh \
      > ${config.xdg.cacheHome}/git-wt/init.zsh
    run ${config.programs.mise.package}/bin/mise activate zsh \
      > ${config.xdg.cacheHome}/mise/activate.zsh
    run ${config.programs.oh-my-posh.package}/bin/oh-my-posh init zsh \
      --config ${config.xdg.configHome}/oh-my-posh/config.json \
      > ${config.xdg.cacheHome}/oh-my-posh/init.zsh
    run ${config.programs.sheldon.package}/bin/sheldon source \
      > ${config.xdg.cacheHome}/sheldon/source.zsh
    run ${config.programs.zoxide.package}/bin/zoxide init zsh \
      > ${config.xdg.cacheHome}/zoxide/init.zsh
    run ${config.programs.zsh.package}/bin/zsh -c \
      'zcompile -R ${config.xdg.cacheHome}/direnv/hook.zsh
       zcompile -R ${config.xdg.cacheHome}/git-wt/init.zsh
       zcompile -R ${config.xdg.cacheHome}/mise/activate.zsh
       zcompile -R ${config.xdg.cacheHome}/oh-my-posh/init.zsh
       zcompile -R ${config.xdg.cacheHome}/sheldon/source.zsh
       zcompile -R ${config.xdg.cacheHome}/zoxide/init.zsh'
  '';

  xdg.configFile."zsh-abbr/user-abbreviations".source = ../../.config/zsh-abbr/user-abbreviations;
}
