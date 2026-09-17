{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/qemu/qemu-guest.nix
  ];

  zramSwap.memoryPercent = lib.mkForce 100;

  customOptions = {
    autologinSettings.getty.enableAutologin = true;
    autologinSettings.guiSession.enableAutologin = true;
    etcMachineID = "fdc6fec191404e99af873d9e081b0ea8";
    #kernelDevelopment.enable = true;
    localCaching.buildsNixDerivations = true;
    persistence.enable = true;
    useMinimalConfig = lib.mkForce false;
  };
}
