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
    "11-enx30c599b9ea65" = {
      matchConfig.Name = "enx30c599b9ea65";
      matchConfig.MACAddress = "30:c5:99:b9:ea:65";
      address = [ "192.168.4.2/24" ];
    };
    "11-enx30c599b9ea69" = {
      matchConfig.Name = "enx30c599b9ea69";
      matchConfig.MACAddress = "30:c5:99:b9:ea:69";
      address = [ "192.168.5.2/24" ];
    };
    "11-enx30c599b9ea66" = {
      matchConfig.Name = "enx30c599b9ea66";
      matchConfig.MACAddress = "30:c5:99:b9:ea:66";
      address = [ "192.168.0.2/24" ];
    };
    "11-enx30c599b9ea6a" = {
      matchConfig.Name = "enx30c599b9ea6a";
      matchConfig.MACAddress = "30:c5:99:b9:ea:6a";
      address = [ "192.168.1.2/24" ];
    };
  };

  networking.networkmanager.unmanaged = [
    "interface-name:enx30c599b9ea65"
    "mac:30:c5:99:b9:ea:65"

    "interface-name:enx30c599b9ea69"
    "mac:30:c5:99:b9:ea:69"

    "interface-name:enx30c599b9ea66"
    "mac:30:c5:99:b9:ea:66"

    "interface-name:enx30c599b9ea6a"
    "mac:30:c5:99:b9:ea:6a"
  ];

  customOptions.socSupport.armSoc = "gb10";
}
