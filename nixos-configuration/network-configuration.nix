{ lib, ... }:

let domainNameServers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" ];

in {
  systemd.network = {
    enable = true;
    wait-online = {
      enable = true;
      anyInterface = true;
    };
  };

  environment.etc."resolv.conf".mode = "direct-symlink";
  services.resolved = {
    enable = true;
    fallbackDns = domainNameServers;
  };

  networking = {
    firewall.enable = false; # this uses iptables AFAIK, use nftables instead
    networkmanager.enable = true;
    nftables.enable = true;
    wireless.enable = lib.mkForce false; # this enabled 'wpa_supplicant', use networkmanager instead
    nameservers = domainNameServers;
  };
}
