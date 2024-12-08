{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  assertions = [{
    assertion = (!config.customOptions.isIso) && config.customOptions.displayServer.guiSession == "cosmic";
    message = ''
      For some reason, COSMIC cannot be enabled on a NixOS ISO because it does not start.
      Remove this once it is no longer the case.
    '';
  }];
}
