{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf config.customOptions.isIso {
  assertions = [{
    assertion = config.customOptions.displayServer.guiSession == "cosmic";
    message = ''
      For some reason, COSMIC cannot be enabled on a NixOS ISO because it does not start.
      Remove this once it is no longer the case.
    '';
  }];
}
