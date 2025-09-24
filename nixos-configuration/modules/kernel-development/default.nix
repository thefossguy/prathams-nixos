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
    ./kdev-host.nix
    ./kdev-vm.nix
  ];
}
