{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  filesystemsMountOptions = nixosSystemConfig.extraConfig.filesystemsMountOptions;
in {
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0659-9795";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/efea71e0-6154-4fb5-b10b-f84dec50c08f";
    fsType = "xfs";
    options = filesystemsMountOptions;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/36ed9313-090d-4f24-995a-6c2c008e05fd";
    fsType = "xfs";
    options = filesystemsMountOptions;
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/1a989d9a-e9d6-4762-b6d4-8c4774ec1d93";
    fsType = "xfs";
    options = filesystemsMountOptions;
  };
}
