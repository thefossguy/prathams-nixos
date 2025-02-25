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
  wgEndpiontIp = "185.159.158.149";
  wgEndpiontCidr = "32";
  wgPublicKey = "We2ZxSzO//srj1br7S2+o8d14qegEf4PKdqKJ46N+34=";
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
