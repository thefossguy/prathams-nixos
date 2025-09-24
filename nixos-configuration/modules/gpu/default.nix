{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  imports = [
    ./amd.nix
    ./intel.nix
    ./nvidia.nix
  ];
}
