{ lib, ... }:

{
  systemd.network.wait-online.anyInterface = lib.mkForce false;
  networking.useDHCP = lib.mkForce false;
}
