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
    gpuSupport = [ "nvidia" ];
    virtualisation.enable = true;
    x86CpuVendor = "amd";
  };
}
