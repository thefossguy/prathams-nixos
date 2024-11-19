{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  domainNameServers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];
in {
  systemd.network = {
    enable = true;
    wait-online.enable = lib.mkForce false; # handled by my custom service
  };

  environment.etc."resolv.conf".mode = "direct-symlink";
  services.resolved = {
    enable = true;
    fallbackDns = domainNameServers;
  };

  networking = {
    firewall.enable = false; # this uses iptables AFAIK, use nftables instead
    nameservers = domainNameServers;
    networkmanager.enable = true;
    nftables.enable = true;
    useDHCP = lib.mkDefault true;
    wireless.enable = lib.mkForce false; # this enabled 'wpa_supplicant', use networkmanager instead
  };
}
