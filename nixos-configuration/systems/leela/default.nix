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
  zramSwap.enable = lib.mkForce false;

  customOptions = {
    dhcpConfig = "ipv6";
    useAlternativeSSHPort = true;
    useMinimalConfig = lib.mkForce false;
  };
}
