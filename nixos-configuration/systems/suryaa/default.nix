{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  systemd.network.networks = {
    "11-enx30c599b9ea5c" = {
      matchConfig.Name = "enx30c599b9ea5c";
      matchConfig.MACAddress = "30:c5:99:b9:ea:5c";
      address = [ "192.168.2.2/24" ];
      linkConfig.MTUBytes = "9000";
    };
    "11-enx30c599b9ea60" = {
      matchConfig.Name = "enx30c599b9ea60";
      matchConfig.MACAddress = "30:c5:99:b9:ea:60";
      address = [ "192.168.3.2/24" ];
      linkConfig.MTUBytes = "9000";
    };
    "11-enx30c599b9ea5d" = {
      matchConfig.Name = "enx30c599b9ea5d";
      matchConfig.MACAddress = "30:c5:99:b9:ea:5d";
      address = [ "192.168.4.1/24" ];
      linkConfig.MTUBytes = "9000";
    };
    "11-enx30c599b9ea61" = {
      matchConfig.Name = "enx30c599b9ea61";
      matchConfig.MACAddress = "30:c5:99:b9:ea:61";
      address = [ "192.168.5.1/24" ];
      linkConfig.MTUBytes = "9000";
    };
  };

  networking.networkmanager.unmanaged = [
    "interface-name:enx30c599b9ea5c"
    "mac:30:c5:99:b9:ea:5c"

    "interface-name:enx30c599b9ea60"
    "mac:30:c5:99:b9:ea:60"

    "interface-name:enx30c599b9ea5d"
    "mac:30:c5:99:b9:ea:5d"

    "interface-name:enx30c599b9ea61"
    "mac:30:c5:99:b9:ea:61"
  ];

  customOptions.socSupport.armSoc = "gb10";
}
