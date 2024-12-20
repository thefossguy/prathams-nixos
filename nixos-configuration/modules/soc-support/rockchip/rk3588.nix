{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.socSupport.armSoc == "rk3588") {
  boot.kernelModules = [ "dw_hdmi_qp" ];
  hardware.deviceTree = {
    enable = true;
    name = nixosSystemConfig.extraConfig.dtbRelativePath;
  };
}
