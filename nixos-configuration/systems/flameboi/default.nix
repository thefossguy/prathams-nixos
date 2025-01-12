{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  customOptions.x86CpuVendor = "amd";
  customOptions.displayServer.guiSession = "kde";
}
