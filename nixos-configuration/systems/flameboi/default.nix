{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  customOptions = {
    displayServer.guiSession = "kde";
    virtualisation.enable = true;
    x86CpuVendor = "amd";
  };
}
