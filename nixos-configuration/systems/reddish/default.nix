{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [ ./hardware-configuration.nix ];

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

  customOptions.podmanContainers.enableHomelabServices = true;
  customOptions.socSupport.armSoc = "rpi4";
}
