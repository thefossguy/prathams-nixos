{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  systemd.network = {
    enable = true;
    wait-online.enable = lib.mkForce false; # handled by my custom service
  };

  environment.etc."resolv.conf".mode = "direct-symlink";
  services.resolved = {
    enable = true;
    dnssec = "true";
    dnsovertls = "true";
    fallbackDns = [
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  networking = {
    dhcpcd.persistent = true;
    enableIPv6 = false;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    tcpcrypt.enable = lib.mkForce false;
    useDHCP = lib.mkDefault true;
    wireless.enable = lib.mkForce false; # This enables `wpa_supplicant`, use `networkmanager` instead.

    nftables = {
      enable = lib.mkForce true;
      checkRuleset = lib.mkForce true;
    };

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    firewall = {
      enable = true;
      checkReversePath = "loose";
      logRefusedConnections = false;
    };

    wireguard = {
      enable = true;
      useNetworkd = true;
    };
  };
}
