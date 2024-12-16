{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ./raspberry-pi
    ./rockchip
    ./z-firmware-updater.nix
  ];
}
