# OMP coding agent. The package and Home Manager module come from the upstream
# flake; runtime-managed settings remain writable under ~/.omp/agent.
{ ... }:
{
  programs.omp.enable = true;
}
