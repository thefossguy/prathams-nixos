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
    device = "/dev/disk/by-uuid/ffffffff-ffff-ffff-ffff-fffffffffff1";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/ffffffff-ffff-ffff-ffff-fffffffffff2";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/ffffffff-ffff-ffff-ffff-fffffffffff3";
    fsType = "xfs";
  };
}
