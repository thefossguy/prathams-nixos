{ ... }:

{
  imports = [
    ../../includes/misc-imports/sudo-nopasswd.nix
    ../../includes/qemu/qemu-binfmt.nix
    ../../includes/qemu/qemu-guest.nix
    ../../includes/zfs/default.nix
  ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FFFF-FFF0";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFF1";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFF2";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFF3";
    fsType = "xfs";
  };
}
