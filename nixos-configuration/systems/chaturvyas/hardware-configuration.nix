{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  zpoolName = "${config.networking.hostName}-zpool";
in
{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3A4D-C659";
  };

  fileSystems."/" = {
    device = "${zpoolName}/root";
    fsType = lib.mkForce "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/home" = {
    device = "${zpoolName}/home";
    fsType = lib.mkForce "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/nas" = {
    device = "${zpoolName}/nas";
    fsType = lib.mkForce "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/var" = {
    device = "${zpoolName}/var";
    fsType = lib.mkForce "zfs";
    options = [ "zfsutil" ];
  };
}
