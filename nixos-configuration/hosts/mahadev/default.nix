{ config, lib, pkgs, systemUser, ... }:

{
  imports = [ ../../includes/display-server/kde-plasma.nix ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B911-786F";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/83cf9d36-a97a-4336-ab3c-e818cc4edc30";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/b8a89e3a-f6d9-456c-a554-6d6fd498ce46";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/7cb3c69f-2c62-4498-86e5-f168b3f2daa4";
    fsType = "xfs";
  };
}
