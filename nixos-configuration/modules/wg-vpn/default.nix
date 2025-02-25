{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  imports = [
    ./vpn-wg0x0.nix
    ./vpn-wg0x1.nix
    ./vpn-wg0x2.nix
  ];

  networking.dhcpcd.runHook = lib.strings.concatStringsSep "\n" config.customOptions.wireguardOptions.routes;
}
