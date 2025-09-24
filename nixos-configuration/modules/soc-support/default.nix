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
    ./devicetree.nix
    ./raspberry-pi
    ./rockchip
    ./z-firmware-updater.nix
  ];
}
