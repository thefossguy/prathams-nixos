{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.socSupport.armSoc == "rk3588") {
  boot.initrd.availableKernelModules = [
    "pcie-rockchip-host"
    "phy-rockchip-emmc"
    "phy-rockchip-naneng-combphy"
    "phy-rockchip-pcie"
  ];
}
