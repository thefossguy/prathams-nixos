{
  config,
  lib,
  pkgs,
  pkgsChannels,
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
  systemd.network = {
    networks = {
      "10-${primaryNetIface}" = {
        matchConfig = {
          Name = primaryNetIface;
        };
        networkConfig = {
          Bridge = lib.mkIf virtualBridgeConditional bridgeIface;
          DHCP = lib.mkForce false;
        };
      } // lib.attrsets.optionalAttrs (!virtualBridgeConditional) staticIpConfig;

      "30-${bridgeIface}" =
        lib.attrsets.optionalAttrs virtualBridgeConditional {
          matchConfig = {
            Name = bridgeIface;
          };
        }
        // staticIpConfig;
    };

    netdevs = {
      "20-${bridgeIface}" = lib.attrsets.optionalAttrs virtualBridgeConditional {
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
