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
    useAlternativeSSHPort = true;
    useMinimalConfig = lib.mkForce false;
  };
}
