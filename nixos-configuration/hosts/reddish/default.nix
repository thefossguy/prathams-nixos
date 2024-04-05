{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b871e4ec-ed69-4cca-81aa-8d69cf5d03ab";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/433E-4CC6";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e2c5f990-09ff-4e0b-88fa-1d10895b829a";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/a8733ba0-628e-4175-a9a9-a5bd226c50fd";
    fsType = "xfs";
  };

  networking.firewall.allowedTCPPorts = [
    8001 # caddy HTTP
    8002 # caddy HTTPS
    8003 # personal blog
    8004 # machine-setup/documentation blog
    8005 # Gitea web UI
    8006 # Gitea SSH
    8008 # Uptime Kuma web UI
    8009 # Transmission web UI
    8010 # Transmission torrent comm port (TCP)
  ];
  networking.firewall.allowedUDPPorts = [
    9001 # Transmission torrent comm port (UDP)
  ];
}
