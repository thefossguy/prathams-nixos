{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ./raspberry-pi
    ./rockchip
    ./u-boot-updater.nix
  ];
}
