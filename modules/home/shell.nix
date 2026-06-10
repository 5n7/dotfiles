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
    # HM's integration emits `eval "$(oh-my-posh init zsh ...)"` at shell start.
    # We pre-render that to a cache file via home.activation below and source it
    # from ./zsh/omp.zsh instead, avoiding the subprocess on every interactive
    # shell.
    enableZshIntegration = false;
    settings = builtins.fromTOML (builtins.readFile ./omp.toml);
  };

  programs.sheldon = {
    enable = true;
    # HM's integration wires `eval "$(sheldon source)"` through the deprecated
    # programs.zsh.initExtra. We disable it and inject via ./zsh/sheldon.zsh
    # in initContent below.
    enableZshIntegration = false;
    settings = {
      plugins = {
        # `0-` prefix sorts first so zsh-defer loads before any plugin using
        # the `defer` template (sheldon emits in plugins.toml file order).
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
    # We manage compinit ourselves (./zsh/compinit.zsh) with daily-cached
    # dumps; HM's auto compinit runs the full security audit on every shell.
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
      ./zsh/homebrew.zsh
      ./zsh/functions.zsh
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

  # Clone any missing plugins after plugins.toml is written. `sheldon lock`
  # is a no-op when the lockfile already matches plugins.toml, so this only
  # hits the network on fresh setup or when the plugin list changes. Refresh
  # upstream commits manually with `sheldon lock --update`.
  home.activation.sheldonLock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${config.programs.sheldon.package}/bin/sheldon lock
  '';

  # Pre-render oh-my-posh, sheldon, and the deferred tool init scripts
  # (direnv/zoxide/git-wt/mise) so interactive shells only need to `source` a
  # file instead of spawning subprocesses + eval. Also zcompile them so zsh
  # can skip the parser on subsequent loads.
  home.activation.precomputeShellInit = lib.hm.dag.entryAfter [ "sheldonLock" ] ''
    run mkdir -p ${config.xdg.cacheHome}/oh-my-posh ${config.xdg.cacheHome}/sheldon \
      ${config.xdg.cacheHome}/direnv ${config.xdg.cacheHome}/zoxide \
      ${config.xdg.cacheHome}/git-wt ${config.xdg.cacheHome}/mise
    run ${config.programs.oh-my-posh.package}/bin/oh-my-posh init zsh \
      --config ${config.xdg.configHome}/oh-my-posh/config.json \
      > ${config.xdg.cacheHome}/oh-my-posh/init.zsh
    run ${config.programs.sheldon.package}/bin/sheldon source \
      > ${config.xdg.cacheHome}/sheldon/source.zsh
    run ${config.programs.direnv.package}/bin/direnv hook zsh \
      > ${config.xdg.cacheHome}/direnv/hook.zsh
    run ${config.programs.zoxide.package}/bin/zoxide init zsh \
      > ${config.xdg.cacheHome}/zoxide/init.zsh
    run ${pkgs-unstable.git-wt}/bin/git-wt --init zsh \
      > ${config.xdg.cacheHome}/git-wt/init.zsh
    run ${config.programs.mise.package}/bin/mise activate zsh \
      > ${config.xdg.cacheHome}/mise/activate.zsh
    run ${config.programs.zsh.package}/bin/zsh -c \
      'zcompile -R ${config.xdg.cacheHome}/oh-my-posh/init.zsh
       zcompile -R ${config.xdg.cacheHome}/sheldon/source.zsh
       zcompile -R ${config.xdg.cacheHome}/direnv/hook.zsh
       zcompile -R ${config.xdg.cacheHome}/zoxide/init.zsh
       zcompile -R ${config.xdg.cacheHome}/git-wt/init.zsh
       zcompile -R ${config.xdg.cacheHome}/mise/activate.zsh'
  '';

  xdg.configFile."zsh-abbr/user-abbreviations".source = ../../.config/zsh-abbr/user-abbreviations;
}
