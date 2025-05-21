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
    ../../modules/qemu/qemu-guest.nix
    ./hardware-configuration.nix
  ];

  boot.kernelParams = [ "console=tty" ];

  customOptions = {
    useMinimalConfig = lib.mkForce false;
    localCaching.servesNixDerivations = true;
  };
}
