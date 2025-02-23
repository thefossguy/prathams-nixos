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
  staticIpConfig = {
    # Fuck the DHCP, we ball
    useDHCP = lib.mkForce false;
    ipv4.addresses = [
      {
        address = nixosSystemConfig.coreConfig.ipv4Address;
        prefixLength = nixosSystemConfig.extraConfig.ipv4PrefixLength;
      }
    ];
  };
in
{
  # While I'd like some of this to go in the networking and virtualisation-specific
  # modules, it maybe belongs here? I don't know.
  environment.systemPackages = lib.optionals virtualBridgeConditional [ pkgs.bridge-utils ];
  networking = {
    defaultGateway = {
      address = nixosSystemConfig.extraConfig.gatewayAddr;
      interface = if virtualBridgeConditional then "virbr0" else primaryNetIface;
    };

    interfaces =
      if virtualBridgeConditional then
        {
          "virbr0" = staticIpConfig;
          "${primaryNetIface}" = {
            useDHCP = lib.mkForce false; # slave to virbr0
            ipv4.addresses = lib.mkForce [ ]; # empty because DHCP is disabled
            ipv6.addresses = lib.mkForce [ ]; # empty because DHCP is disabled
          };
        }
      else
        {
          "${primaryNetIface}" = staticIpConfig;
        };

    bridges = lib.attrsets.optionalAttrs virtualBridgeConditional {
      "virbr0" = {
        rstp = lib.mkForce false;
        interfaces = [ "${primaryNetIface}" ];
      };
    };
  };

  systemd.network.networks = lib.attrsets.optionalAttrs virtualBridgeConditional {
    "40-${primaryNetIface}" = {
      matchConfig = {
        Name = primaryNetIface;
      };
      linkConfig = {
        Unmanaged = "yes";
        ActivationPolicy = "manual";
      };
      networkConfig = {
        LinkLocalAddressing = "no";
        DHCP = "no";
      };
    };
  };
}
