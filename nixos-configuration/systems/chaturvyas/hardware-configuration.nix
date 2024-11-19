{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let zpoolName = "${config.networking.hostName}-zpool";
in {
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3A4D-C659";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "${zpoolName}/root";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/home" = {
    device = "${zpoolName}/home";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/nas" = {
    device = "${zpoolName}/nas";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/var" = {
    device = "${zpoolName}/var";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };
}
