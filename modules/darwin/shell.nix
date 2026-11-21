# System-wide zsh (/etc/zshrc), sourced before ~/.config/zsh/.zshrc. nix-darwin
# enables these by default, and each slows every interactive shell for work that
# modules/home/shell.nix already does or doesn't need.
{ ... }:
{
  programs.zsh = {
    # bashcompinit, for bash-only completions that nothing here uses.
    enableBashCompletion = false;

    # Bare `compinit`: full compaudit scan (~70ms) plus a second dump in
    # ~/.config/zsh/.zcompdump that modules/home/zsh/compinit.zsh supersedes.
    enableCompletion = false;

    # A promptinit round trip to set a prompt oh-my-posh overwrites.
    promptInit = "";
  };
}
