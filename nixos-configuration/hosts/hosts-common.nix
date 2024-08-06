{ lib, pkgs, hostname, gatewayAddr, hostId, ipv4Address, ipv4PrefixLength
, networkingIface, latestStableKernel, supportedFilesystemsSansZFS, system, ... }:

{
  imports = [
    ../includes/zfs/default.nix
    ../includes/local-nix-cache/default.nix
  ];

  boot.kernelPackages = lib.mkDefault pkgs."${latestStableKernel}";
  boot.supportedFilesystems = lib.mkDefault supportedFilesystemsSansZFS;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  networking = {
    hostId = hostId;
    hostName = hostname;

    defaultGateway = {
      address = gatewayAddr;
      interface = networkingIface;
    };

    # use dhcp for the rest of the interfaces
    useDHCP = lib.mkDefault true;
    interfaces = {
      "${networkingIface}" = {
        # fuck the dhcp, we ball
        useDHCP = lib.mkForce false;
        ipv4.addresses = [{
          address = ipv4Address;
          prefixLength = ipv4PrefixLength;
        }];
      };
    };
  };

  # this should actually be in ../configuration.nix
  # but I don't have a way to pass in `system`
  # without a **lot** of duplication in 'flake.nix'
  nixpkgs.hostPlatform = system;
}
