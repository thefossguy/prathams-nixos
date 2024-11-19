{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/61A5-09DA";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/584bb45a-cf2a-41ce-ad18-5465ade109ce";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/21230fc0-6bdd-4572-bfea-55a0c6ec015d";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/e8ec889d-45ad-4f83-9217-93c5fe9c13ef";
    fsType = "xfs";
  };
}
