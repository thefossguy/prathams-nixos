{ lib, ... }:

{
  imports = [
    ../../includes/autologin/default.nix
    #../../includes/display-server/kde-plasma.nix
    ../../includes/misc-imports/sudo-nopasswd.nix
    #../../includes/qemu/qemu-binfmt.nix
    ../../includes/qemu/qemu-guest.nix
  ];

  zramSwap.memoryPercent = lib.mkForce 50;
  zramSwap.swapDevices = lib.mkForce 2;

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/05ED-4450";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/05ed4456-f187-4511-8df3-f93068267a61";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/05ed4456-f187-4511-8df3-f93068267a62";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/05ed4456-f187-4511-8df3-f93068267a63";
    fsType = "xfs";
  };
}
