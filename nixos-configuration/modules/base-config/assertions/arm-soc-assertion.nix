{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.socSupport.armSoc != "unset") {
  assertions = [{
    assertion = (pkgs.stdenv.isAarch64 && nixosSystemConfig.coreConfig.isNixOS);
    message = "The option `customOptions.socSupport.armSoc` can only be set on NixOS on Aarch64.";
  }];
}
