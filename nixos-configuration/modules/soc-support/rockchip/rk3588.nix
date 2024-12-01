{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.socSupport.armSoc == "rk3588") {
  boot.initrd.availableKernelModules = [
    "phy-rockchip-pcie"
    "pcie-rockchip-host"
  ];
}
