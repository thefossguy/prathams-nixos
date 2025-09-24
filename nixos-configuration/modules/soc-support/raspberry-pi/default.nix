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
    ./common-rpi-config.nix
    ./rpi4.nix
    ./rpi5.nix
  ];
}
