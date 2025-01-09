{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/qemu/qemu-guest.nix
  ];

  zramSwap.memoryPercent = lib.mkForce 100;

  customOptions = {
    autologinSettings.getty.enableAutologin = true;
    autologinSettings.guiSession.enableAutologin = true;
    enablePasswordlessSudo = true;
    kernelDevelopment.enable = true;
    localCaching.buildsNixDerivations = true;
    useMinimalConfig = lib.mkForce false;
  };
}
