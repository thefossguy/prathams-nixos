{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  # Not really "hardware-configuration" (not critical to boot) but this is here
  # because it is kind of related.
  boot.zfs.extraPools = [ "heathen_disk" ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EC29-F4CC";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3686a347-b9f6-4991-857e-24a7699768a6";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/6143e45b-2a9e-4016-bd8d-05ee82c1bc9e";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/fc0fc41b-ec67-49b6-ac3f-894fab9758d9";
  };
}
