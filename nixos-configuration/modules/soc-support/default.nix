{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ./devicetree.nix
    ./raspberry-pi
    ./rockchip
    ./z-firmware-updater.nix
  ];
}
