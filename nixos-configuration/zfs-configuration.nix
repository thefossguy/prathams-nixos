{ config, pkgs, ... }:

{
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportAll = true;
  };

  services.zfs = {
    autoReplication.enable = false;

    trim = {
      enable = true;
      interval = "Fri *-*-01..07 08:00:00";
    };

    autoScrub = {
      enable = true;
      interval = "Sat *-*-01..07 08:00:00";
    };
  };

  virtualisation.lxd.zfsSupport = true;
}
