{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  wgIfaceName = "wg0x1";
  wgEndpointIp = "79.135.104.85";
  wgEndpiontCidr = "32";
  wgPublicKey = "tEz96jcHEtBtZOmwMK7Derw0AOih8usKFM+n4Svhr1E=";
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
