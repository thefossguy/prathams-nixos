{ config, ... }:

let
  zpoolName = "${config.networking.hostName}-zpool";
in

{
  imports = [
    ../../includes/zfs/default.nix
    ../../systemd-services/git-sync.nix
  ];

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

  fileSystems."/var" = {
    device = "${zpoolName}/var";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };
}
