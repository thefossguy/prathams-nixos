{ lib, ... }:

{
  boot.kernel = {
    sysctl = {
      "net.ipv4.conf.all.forwarding" = true; # toggle IPv4 forwarding
      "net.ipv6.conf.all.forwarding" = true; # toggle IPv6 forwarding
    };
  };

  systemd.network.wait-online.anyInterface = lib.mkForce false;
  networking.useDHCP = lib.mkForce false;
}
