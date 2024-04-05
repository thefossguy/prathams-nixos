{ config
, lib
, pkgs
, hostname
, forceLtsKernel ? false
, gatewayAddr
, hostId
, ipv4Address
, ipv4PrefixLength
, networkingIface
, supportedFilesystemsSansZFS
, system
, systemUser
, ...
}:

{
  boot = {
    kernelPackages = if forceLtsKernel
      then pkgs.linuxPackages
      else pkgs.linuxPackages_latest;

    # no need to lib.mkForce because ZFS is only enabled in the ISO's config; nowhere else
    supportedFilesystems = supportedFilesystemsSansZFS
      ++ (if forceLtsKernel
        then [ "zfs" ]
        else []);

    zfs.forceImportAll = !forceLtsKernel;
  };

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
