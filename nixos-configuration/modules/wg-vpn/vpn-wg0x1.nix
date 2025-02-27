{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  wgIfaceName = "wg0x1";
  wgEndpiontIp = "79.135.104.85";
  wgEndpiontCidr = "32";
  wgPublicKey = "tEz96jcHEtBtZOmwMK7Derw0AOih8usKFM+n4Svhr1E=";
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
