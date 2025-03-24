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
  boot.kernelModules =
    lib.optionals (lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.13")
      [
        "dw_hdmi_qp"
      ];
}
