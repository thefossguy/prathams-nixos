{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  customOptions.cpuMicrocodeVendor = "amd";
  customOptions.displayServer.guiSession = "kde";
}
