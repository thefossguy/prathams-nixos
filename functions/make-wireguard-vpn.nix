{
  config,
  lib,
  pkgs,
  nixosSystemConfig,
  ifaceEnabled,
  wgEndpointIp,
  wgEndpointCidr,
  wgIfaceName,
  wgLocalIp,
  wgPublicKey,
  ...
}:

lib.mkIf ifaceEnabled {
  systemd.network = {
    networks."10-${wgIfaceName}" = {
      matchConfig = {
        Name = wgIfaceName;
      };
      networkConfig = {
        Address = wgLocalIp;
      };
      routes = [
        {
          Destination = "${wgEndpointIp}/${wgEndpointCidr}";
          Gateway = nixosSystemConfig.extraConfig.gatewayAddr;
        }
      ];
    };

    netdevs."10-${wgIfaceName}" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = wgIfaceName;
      };
      wireguardPeers = [
        {
          AllowedIPs = [ "0.0.0.0/0" ];
          Endpoint = "${wgEndpointIp}:51820";
          PublicKey = wgPublicKey;
          PersistentKeepalive = 2;
        }
      ];
      wireguardConfig = {
        PrivateKeyFile = "${config.customOptions.wireguardOptions.wgPrivateKeyDir}/${wgIfaceName}.priv";
      };
    };
  };
}
