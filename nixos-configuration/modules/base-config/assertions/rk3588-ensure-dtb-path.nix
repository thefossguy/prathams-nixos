{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.socSupport.armSoc == "rk3588") {
  assertions = [{
    assertion = nixosSystemConfig.extraConfig.dtbRelativePath != null;
    message = "You need to provide a path relative to `dtbs/` for the device-tree binary for your board.";
  }];
}
