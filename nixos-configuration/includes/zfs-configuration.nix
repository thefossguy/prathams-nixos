{ pkgs, ... }:

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
      pools = []; # empty list means all zpools
    };
  };

  environment.systemPackages = with pkgs; [
    linuxKernel.packages.linux_6_6.zfs
  ];

  virtualisation.lxd.zfsSupport = true;
}
