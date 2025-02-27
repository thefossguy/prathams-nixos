{
  lib,
  pkgs,
  nixosSystemConfig,
  ifaceEnabled,
  wgEndpointIp,
  wgEndpiontCidr,
  wgIfaceName,
  wgLocalIp,
  wgPublicKey,
  ...
}:

lib.mkIf ifaceEnabled {
  customOptions.wireguardOptions.routes = [
    "${pkgs.iproute2}/bin/ip route add ${wgEndpointIp}/${wgEndpiontCidr} via ${nixosSystemConfig.extraConfig.gatewayAddr} dev ${nixosSystemConfig.coreConfig.primaryNetIface}"
  ];

  networking.wireguard.interfaces = {
    "${wgIfaceName}" = {
      # If `networking.wireguard.useNetworkd` is enabled,
      # the interface is **deleted** and brought up at said interval, not good.
      dynamicEndpointRefreshSeconds = 0; # with `networking.wireguard.useNetworkd` enabled, the iface goes down and up so disable it
      privateKeyFile = "/etc/nixos/nixos-configuration/modules/wg-vpn/${wgIfaceName}.priv";
      ips = [ "${wgLocalIp}/${wgEndpiontCidr}" ];

      peers = [
        {
          publicKey = wgPublicKey;
          endpoint = "${wgEndpointIp}:51820";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
  };
}
