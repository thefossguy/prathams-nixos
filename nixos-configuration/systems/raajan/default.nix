{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  customOptions = {
    socSupport.armSoc = "rpi5";
    podmanContainers.enableHomelabServices = true;
  };
}
