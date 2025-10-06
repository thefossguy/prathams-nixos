{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  zpoolName = "${config.networking.hostName}-zpool";
in
{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BAFD-2C9F";
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

  fileSystems."/var" = {
    device = "${zpoolName}/var";
    fsType = lib.mkForce "zfs";
    options = [ "zfsutil" ];
  };
}
