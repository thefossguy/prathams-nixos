{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/qemu/qemu-guest.nix
  ];

  boot.kernelParams = [ "console=ttyS0" ];

  # Host has zramswap enabled, not necessary inside guest
  zramSwap.enable = lib.mkForce false;

  customOptions = {
    autologinSettings.getty.enableAutologin = true;
    autologinSettings.guiSession.enableAutologin = true;
    enablePasswordlessSudo = true;
    kernelDevelopment.enable = true;
    useMinimalConfig = lib.mkForce false;
    virtualisation.enable = true;
    virtualisation.enableVirtualBridge = lib.mkForce false;
    x86CpuVendor = "intel";
  };
}
