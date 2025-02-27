{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  wgIfaceName = "wg0x0";
  wgEndpointIp = "185.159.158.77";
  wgEndpiontCidr = "32";
  wgPublicKey = "8PG6wZzij1kPTYivtEh4bNbTrP/WOVQBja9g2+8/i3A=";
  wgLocalIp = "10.2.0.2";
in

import ../../../functions/make-wireguard-vpn.nix {
  ifaceEnabled = (builtins.elem wgIfaceName config.customOptions.wireguardOptions.enabledVPNs);
  inherit
    config
    lib
    pkgs
    nixosSystemConfig
    ;
  inherit
    wgEndpointIp
    wgEndpiontCidr
    wgIfaceName
    wgLocalIp
    wgPublicKey
    ;
}
