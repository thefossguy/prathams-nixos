{ lib, pkgs, hostname, gatewayAddr, hostId, ipv4Address, ipv4PrefixLength
, networkingIface, latestStableKernel, supportedFilesystemsSansZFS, system, config, ... }:

let
  staticIpConfig = {
    # fuck the dhcp, we ball
    useDHCP = lib.mkForce false;
    ipv4.addresses = [{
      address = ipv4Address;
      prefixLength = ipv4PrefixLength;
    }];
  };
in

{
  imports = [
    ../modules/zfs/default.nix
    ../modules/local-nix-cache/default.nix
    ../modules/misc-imports/ether-dev-names-with-mac-addr.nix
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
    useDHCP = lib.mkDefault true;

    defaultGateway = {
      address = gatewayAddr;
      interface = if (config.custom-options.runsVirtualMachines or false)
        then "virbr0"
        else networkingIface ;
    };

    interfaces = if (config.custom-options.runsVirtualMachines or false)
      then {
        "virbr0" = staticIpConfig;
        "${networkingIface}".useDHCP = lib.mkForce false; # slave to virbr0
      } else {
        "${networkingIface}" = staticIpConfig;
      };

    bridges = lib.mkIf (config.custom-options.runsVirtualMachines or false) {
      "virbr0" = {
        rstp = lib.mkForce false;
        interfaces = [
          "${networkingIface}"
        ];
      };
    };
  };

  # this should actually be in ../configuration.nix
  # but I don't have a way to pass in `system`
  # without a **lot** of duplication in 'flake.nix'
  nixpkgs.hostPlatform = system;
}
