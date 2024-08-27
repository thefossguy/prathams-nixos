{ config, lib, pkgs, nixosSystem, ... }:

let
  staticIpConfig = {
    # fuck the dhcp, we ball
    useDHCP = lib.mkForce false;
    ipv4.addresses = [{
      address = nixosSystem.ipv4Address;
      prefixLength = nixosSystem.ipv4PrefixLength;
    }];
  };
in {
  imports = [
    ../modules/zfs/default.nix
    ../modules/local-nix-cache/default.nix
    ../modules/misc-imports/ether-dev-names-with-mac-addr.nix
  ];

  boot.kernelPackages = lib.mkDefault pkgs."${nixosSystem.latestStableKernel}";
  boot.supportedFilesystems = lib.mkDefault nixosSystem.supportedFilesystemsSansZFS;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  networking = {
    hostId = nixosSystem.hostId;
    hostName = nixosSystem.hostname;
    useDHCP = lib.mkDefault true;

    defaultGateway = {
      address = nixosSystem.gatewayAddr;
      interface = if (config.custom-options.runsVirtualMachines or false)
        then "virbr0"
        else nixosSystem.networkingIface;
    };

    interfaces = if (config.custom-options.runsVirtualMachines or false)
      then {
        "virbr0" = staticIpConfig;
        "${nixosSystem.networkingIface}".useDHCP = lib.mkForce false; # slave to virbr0
      } else {
        "${nixosSystem.networkingIface}" = staticIpConfig;
      };

    bridges = lib.mkIf (config.custom-options.runsVirtualMachines or false) {
      "virbr0" = {
        rstp = lib.mkForce false;
        interfaces = [ "${nixosSystem.networkingIface}" ];
      };
    };
  };

  # this should actually be in ../configuration.nix
  # but I don't have a way to pass in `system`
  # without a **lot** of duplication in 'flake.nix'
  nixpkgs.hostPlatform = nixosSystem.system;
}
