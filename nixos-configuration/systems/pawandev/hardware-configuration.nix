{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/46BD-A6DC";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d91a6ad1-bff4-43bd-bddd-2936a4f1078b";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/a1e5cb2c-2863-4ee7-be1f-5b32f7eb9d16";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/28cc2d02-e91b-4368-81e5-d65b9d8a50f3";
    fsType = "xfs";
  };
}
