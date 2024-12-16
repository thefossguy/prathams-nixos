{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  filesystemsMountOptions = nixosSystemConfig.extraConfig.filesystemsMountOptions;
in {
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4BA2-293A";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2989f94f-7246-4caf-a292-980062486f83";
    fsType = "xfs";
    options = filesystemsMountOptions;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/4198f8e7-b8c5-4b05-9380-a86676d17f8d";
    fsType = "xfs";
    options = filesystemsMountOptions;
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/6e74eb89-4949-44bb-8012-1f342107e31a";
    fsType = "xfs";
    options = filesystemsMountOptions;
  };
}
