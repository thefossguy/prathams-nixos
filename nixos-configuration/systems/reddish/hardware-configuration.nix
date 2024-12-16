{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  filesystemsMountOptions = nixosSystemConfig.extraConfig.filesystemsMountOptions;
in {
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/15D7-1EF4";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c78f0691-a246-4b01-bb33-41662abcb2d6";
    fsType = "xfs";
    options = filesystemsMountOptions;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/9f8f26e5-5fc3-4f4a-ae45-4f24151e846e";
    fsType = "xfs";
    options = filesystemsMountOptions;
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/cb9dcd35-891b-438f-baa1-fd3278dc3069";
    fsType = "xfs";
    options = filesystemsMountOptions;
  };
}
