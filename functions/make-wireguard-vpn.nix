{
  config,
  lib,
  pkgs,
  nixosSystemConfig,
  ifaceEnabled,
  wgEndpiontIp,
  wgEndpiontCidr,
  wgIfaceName,
  wgLocalIp,
  wgPublicKey,
  ...
}:

lib.mkIf ifaceEnabled {
  customOptions.wireguardOptions.routes = [
    "${pkgs.iproute2}/bin/ip route add ${wgEndpiontIp}/${wgEndpiontCidr} via ${nixosSystemConfig.extraConfig.gatewayAddr} dev ${nixosSystemConfig.coreConfig.primaryNetIface}"
  ];

  networking.wireguard.interfaces = {
    "${wgIfaceName}" = {
      # If `networking.wireguard.useNetworkd` is enabled,
      # the interface is **deleted** and brought up at said interval, not good.
      dynamicEndpointRefreshSeconds = if config.networking.wireguard.useNetworkd then 0 else 30;
      privateKeyFile = "/etc/nixos/nixos-configuration/modules/wg-vpn/${wgIfaceName}.priv";
      ips = [ "${wgLocalIp}/${wgEndpiontCidr}" ];

      peers = [
        {
          publicKey = wgPublicKey;
          endpoint = "${wgEndpiontIp}:51820";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
  };
}

