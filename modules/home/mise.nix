# mise tool version manager. Binary + mise's own settings are managed here;
# per-project tool versions stay dynamic via mise CLI and per-repo `.mise.toml`.
{ ... }:
{
  programs.mise = {
    enable = true;
    # Activation runs via modules/home/zsh/deferred.zsh under zsh-defer to
    # keep interactive shell startup fast; HM's default eager integration
    # would duplicate it.
    enableZshIntegration = false;
    settings = {
      experimental = true;
      python.uv_venv_auto = true;
      status.missing_tools = "always";
    };
  };
}
