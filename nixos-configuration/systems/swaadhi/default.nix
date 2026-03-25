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
    enablePasswordlessSudo = true;
    useMinimalConfig = lib.mkForce false;
  };
}
