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
  primaryNetIface' = "virbr0";
in
{
  # While I'd like some of this to go in the networking and virtualisation-specific
  # modules, it maybe belongs here? I don't know.
  environment.systemPackages = lib.optionals virtualBridgeConditional [ pkgs.bridge-utils ];
  systemd.network = {
    netdevs = {
      "40-${primaryNetIface'}" = lib.attrsets.optionalAttrs virtualBridgeConditional {
        netdevConfig = {
          Name = primaryNetIface';
          Kind = "bridge";
        };
        bridgeConfig = {
          STP = lib.mkForce false;
        };
      };
    };
    networks = {
      "40-${primaryNetIface'}" = {
        matchConfig = {
          Name = primaryNetIface';
        };
        linkConfig = lib.attrsets.optionalAttrs virtualBridgeConditional {
          Unmanaged = "yes";
          ActivationPolicy = "manual";
        };
        address = [ "${nixosSystemConfig.coreConfig.ipv4Address}/${nixosSystemConfig.extraConfig.ipv4PrefixLength}" ];
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
        networkConfig = {
          LinkLocalAddressing = lib.mkIf virtualBridgeConditional "no";
          DHCP = "no";
          Bridge = lib.mkIf virtualBridgeConditional primaryNetIface;
        };
      };
    };
  };
}
