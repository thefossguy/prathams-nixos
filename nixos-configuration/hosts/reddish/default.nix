{ ... }:

{
  imports = [ ../../includes/raspberry-pi/4/default.nix ];

  custom-options.enableWebRemoteServices = true;
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

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/15D7-1EF4";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c78f0691-a246-4b01-bb33-41662abcb2d6";
    fsType = "xfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/9f8f26e5-5fc3-4f4a-ae45-4f24151e846e";
    fsType = "xfs";
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/cb9dcd35-891b-438f-baa1-fd3278dc3069";
    fsType = "xfs";
  };
}
