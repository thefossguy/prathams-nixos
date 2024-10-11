{ lib, ... }:

{
  imports = [
    ../../modules/gpu/intel-xe.nix
    ../../modules/misc-imports/sudo-nopasswd.nix
    ../../modules/qemu/qemu-binfmt.nix
  ];

  boot.extraModprobeConfig = "options kvm_intel nested=1";
  custom-options.runsVirtualMachines = true;
  hardware.bluetooth.enable = lib.mkForce false;

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2243-C1B4";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a7b23478-37c9-4004-aac2-a7d0efde46a7";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/2ced6246-5702-4a76-a167-f90121d3e54c";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/ccff8897-d465-44de-9f8b-1faf8dc66a63";
    fsType = "xfs";
  };
}