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
    displayServer.guiSession = "cosmic";
    gpuSupport = [ "nvidia" ];
    localCaching.buildsNixDerivations = true;
    useMinimalConfig = lib.mkForce false;
    virtualisation.enable = true;
    x86CpuVendor = "amd";
  };
}
