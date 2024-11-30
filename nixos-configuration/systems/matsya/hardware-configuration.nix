{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  filesystemsMountOptions = nixosSystemConfig.extraConfig.filesystemsMountOptions;
in {
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2243-C1B4";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a7b23478-37c9-4004-aac2-a7d0efde46a7";
    fsType = "xfs";
    options = filesystemsMountOptions;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/2ced6246-5702-4a76-a167-f90121d3e54c";
    fsType = "xfs";
    options = filesystemsMountOptions;
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/ccff8897-d465-44de-9f8b-1faf8dc66a63";
    fsType = "xfs";
    options = filesystemsMountOptions;
  };
}
