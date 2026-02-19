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

  services.resolved.enable = lib.mkForce false;
  services.unbound = {
    enable = lib.mkForce true;
    settings = {
      forward-zone = lib.mkForce [ ]; # Enforce "full recursive mode" by assigning an empty list here
      server = {
        interface = [ "127.0.0.1" ];
        access-control = [ "127.0.0.1 allow" ];
        # Some options were taken from <https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound>
        harden-glue = true;
        harden-dnssec-stripped = true;
        prefetch = true;
        edns-buffer-size = 1232;
        use-caps-for-id = false;
        hide-identity = true;
        hide-version = true;

        # A `dig +dnssec DS fastly.net @1.1.1.1` shows that `NSEC3` is
        # being returned. Which is proof of non-existence [of DNSSEC].
        # And yes, this isn't handled by the `harden-dnssec-stripped`
        # option.
        domain-insecure = "fastly.net";
      };
    };
  };
  assertions = [
    {
      assertion = !(config.services.resolved.enable);
      message = "Please toggle off `services.resolved.enable`.";
    }
    {
      assertion = config.services.unbound.enable;
      message = "Please toggle on `services.unbound.enable`.";
    }
  ];

  networking = {
    dhcpcd.persistent = true;
    enableIPv6 = false;
    nameservers = lib.mkForce [ "127.0.0.1" ];
    tcpcrypt.enable = lib.mkForce false;
    useDHCP = lib.mkDefault true;
    wireless.enable = lib.mkForce false; # This enables `wpa_supplicant`, use `networkmanager` instead.

    nftables = {
      enable = lib.mkForce true;
      checkRuleset = lib.mkForce true;
    };

    networkmanager = {
      enable = true;
      dns = "none";
      wifi.backend = "iwd";
      connectionConfig = {
        "ipv4.ignore-auto-dns" = true;
        "ipv6.ignore-auto-dns" = true;
      };
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
