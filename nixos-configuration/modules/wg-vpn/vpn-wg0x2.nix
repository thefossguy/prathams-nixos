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
  wgEndpiontIp = "79.135.104.69";
  wgEndpiontCidr = "32";
  wgPublicKey = "ievGDrxV0dKcjO7EM662c1Ziy0PVct0Ujse3CT4NQQw=";
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
