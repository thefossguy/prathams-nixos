{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  customOptions = {
    fileSystems = {
      UUIDs = {
        boot = "3F17-D0CC";
        root = "ec897753-a6cf-464d-ac29-070085443395";
      };
    };

    luksDevice = {
      UUID = "d49ebdeb-6bbc-4175-827a-5f44859942c3";
      bypassWorkqueues = true;
      challengeStringHex = "401b09eab3c013d4ca54922bb802bec8fd5318192b0a75f201d8b3727429080fb337591abd3e44453b954555b7a0812e1081c39b740293f765eae731f5a65ed1";
    };
  };

  boot.kernelParams = [ "console=tty0" "console=ttyS0" ];

  fileSystems."/boot" = {
    device = config.customOptions.fileSystems.devices.boot;
  };

  fileSystems."/" = {
    device = config.customOptions.fileSystems.devices.root;
    fsType = lib.mkForce "btrfs";
    options = [
      "subvol=@"
      "compress=zstd:15"
    ];
  };

  fileSystems."/nix" = {
    device = config.customOptions.fileSystems.devices.root;
    fsType = lib.mkForce "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd:15"
    ];
  };

  fileSystems."/home" = {
    device = config.customOptions.fileSystems.devices.root;
    fsType = lib.mkForce "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd:15"
    ];
  };

  fileSystems."/var" = {
    device = config.customOptions.fileSystems.devices.root;
    fsType = lib.mkForce "btrfs";
    options = [
      "subvol=@var"
      "compress=zstd:15"
    ];
  };
}
