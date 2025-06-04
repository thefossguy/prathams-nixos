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
    ../../modules/host-modules/firewall-rules.nix
    ../../modules/qemu/qemu-guest.nix
    ./hardware-configuration.nix
  ];

  boot.kernelParams = [ "console=tty" ];
  services.nix-serve.secretKeyFile = lib.mkForce null;
  zramSwap.enable = lib.mkForce false;

  customOptions = {
    dhcpConfig = "ipv6";
    localCaching.servesNixDerivations = true;
    useMinimalConfig = lib.mkForce false;
  };
}
