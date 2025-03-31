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
    displayServer.guiSession = "hyprland";
    gpuSupport = [ "nvidia" ];
    localCaching.buildsNixDerivations = true;
    useMinimalConfig = lib.mkForce false;
    virtualisation.enable = true;
    x86CpuVendor = "amd";
  };
}
