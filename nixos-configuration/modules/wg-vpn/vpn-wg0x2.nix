{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  wgIfaceName = "wg0x2";
  wgEndpiontIp = "185.159.156.162";
  wgEndpiontCidr = "32";
  wgPublicKey = "cFQgn6VKZphGOdOGHux2xUf/QBWSExfg6koDuU68k28=";
  wgIp = "10.2.0.2";
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
    wgEndpiontIp
    wgEndpiontCidr
    wgIfaceName
    wgIp
    wgPublicKey
    ;
}
