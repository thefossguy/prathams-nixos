{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.socSupport.armSoc == "rk3588") {
  boot.initrd.availableKernelModules = [
    "phy_rockchip_naneng_combphy"
  ];
  boot.kernelModules = [ "dw_hdmi_qp" ];
}
