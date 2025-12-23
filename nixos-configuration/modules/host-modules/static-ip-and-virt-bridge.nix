{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  virtualBridgeConditional = config.customOptions.virtualisation.enableVirtualBridge;
  primaryNetIface = nixosSystemConfig.coreConfig.primaryNetIface;
  bridgeIface = "virbr0";
  staticIpConfig = {
    address = [
      "${nixosSystemConfig.coreConfig.ipv4Address}/${builtins.toString nixosSystemConfig.extraConfig.ipv4PrefixLength}"
    ];
    routes = [
      {
        Gateway = nixosSystemConfig.extraConfig.gatewayAddr;
        # If set to true, the kernel does not have to check if the
        # gateway is reachable directly by the current machine
        # (i.e., attached to the local network), so that we can insert
        # the route in the kernel table without it being complained about.
        GatewayOnLink = (config.networking.hostName == "hans");
      }
    ];
  };
in
{
  # While I'd like some of this to go in the networking and virtualisation-specific
  # modules, it maybe belongs here? I don't know.
  environment.systemPackages = lib.optionals virtualBridgeConditional [ pkgs.bridge-utils ];
  systemd.network = lib.attrsets.optionalAttrs (!nixosSystemConfig.extraConfig.useDHCP) {
    networks = {
      "10-r8169-fixup" = lib.attrsets.optionalAttrs (nixosSystemConfig.coreConfig.addrMAC != null) {
        matchConfig = {
          Driver = "r8169";
        };
        linkConfig = {
          MACAddress = nixosSystemConfig.coreConfig.addrMAC;
        };
      };
      "11-${primaryNetIface}" = {
        matchConfig = {
          Name = primaryNetIface;
        };
        networkConfig = {
          Bridge = lib.mkIf virtualBridgeConditional bridgeIface;
          DHCP = lib.mkForce config.customOptions.dhcpConfig;
        };
      }
      // lib.attrsets.optionalAttrs (!virtualBridgeConditional) staticIpConfig;

    }
    // lib.attrsets.optionalAttrs virtualBridgeConditional {
      "30-${bridgeIface}" = {
        matchConfig = {
          Name = bridgeIface;
        };
      }
      // staticIpConfig;
    };

    netdevs = lib.attrsets.optionalAttrs virtualBridgeConditional {
      "20-${bridgeIface}" = {
        netdevConfig = {
          Name = bridgeIface;
          Kind = "bridge";
        };
        bridgeConfig = {
          STP = lib.mkForce false;
        };
      };
    };
  };
}
