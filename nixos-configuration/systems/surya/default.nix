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
    "11-enx30c599b9f623" = {
      matchConfig.Name = "enx30c599b9f623";
      matchConfig.MACAddress = "30:c5:99:b9:f6:23";
      address = [ "192.168.0.1/24" ];
      linkConfig.MTUBytes = "9000";
    };
    "11-enx30c599b9f627" = {
      matchConfig.Name = "enx30c599b9f627";
      matchConfig.MACAddress = "30:c5:99:b9:f6:27";
      address = [ "192.168.1.1/24" ];
      linkConfig.MTUBytes = "9000";
    };
    "11-enx30c599b9f624" = {
      matchConfig.Name = "enx30c599b9f624";
      matchConfig.MACAddress = "30:c5:99:b9:f6:24";
      address = [ "192.168.2.1/24" ];
      linkConfig.MTUBytes = "9000";
    };
    "11-enx30c599b9f628" = {
      matchConfig.Name = "enx30c599b9f628";
      matchConfig.MACAddress = "30:c5:99:b9:f6:28";
      address = [ "192.168.3.1/24" ];
      linkConfig.MTUBytes = "9000";
    };
  };

  networking.networkmanager.unmanaged = [
    "interface-name:enx30c599b9f623"
    "mac:30:c5:99:b9:f6:23"

    "interface-name:enx30c599b9f627"
    "mac:30:c5:99:b9:f6:27"

    "interface-name:enx30c599b9f624"
    "mac:30:c5:99:b9:f6:24"

    "interface-name:enx30c599b9f628"
    "mac:30:c5:99:b9:f6:28"
  ];

  customOptions.socSupport.armSoc = "gb10";
}
