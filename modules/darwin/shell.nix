# System-wide zsh (/etc/zshrc), sourced before ~/.config/zsh/.zshrc. nix-darwin
# enables these by default and every one duplicates what modules/home/shell.nix
# already does, so each interactive shell paid for them twice.
{ ... }:
{
  programs.zsh = {
    # bashcompinit on top of the compinit below, for bash-only completions.
    enableBashCompletion = false;

    # Bare `compinit`: full compaudit scan (~70ms) plus a second dump in
    # ~/.config/zsh/.zcompdump that ./zsh/compinit.zsh then supersedes.
    enableCompletion = false;

    # A promptinit round trip to set a prompt oh-my-posh overwrites.
    promptInit = "";
  };
}
