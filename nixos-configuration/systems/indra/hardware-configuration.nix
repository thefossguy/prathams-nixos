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
       boot = "2C9D-5832";
       root = "28e0f5b3-b5c6-41bf-8b7c-2c6fd9aa1515";
     };
    };

    luksDevice = {
      UUID = "0529936e-2e31-47bf-918d-ee0c2f277c23";
      bypassWorkqueues = true;
      challengeString = "asdf";
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
