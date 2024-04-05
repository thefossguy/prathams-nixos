{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  imports = [ ../../includes/display-server/kde-plasma.nix ];

  boot.kernelPatches = [{
    name = "revert-of-patch-for-rock-5b";
    patch = ./0001-Revert-of-property-fw_devlink-Fix-stupid-bug-in-remo.patch;
  }];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8c2b0c8c-3979-4332-855f-f9badf24e86d";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5913-D589";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e73e491a-fd04-4688-8f6a-f64ae500692b";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/73451b12-4144-424e-a574-26957b0c988c";
    fsType = "xfs";
  };
}
