{ config, pkgs, ... }:

{
  services = {
    timesyncd.enable = true; # NTP

    fwupd.enable = true;

    openssh = {
      enable = true;
      extraConfig = "PermitEmptyPasswords no";
      ports = [ 22 ];
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
        X11Forwarding = false;
      };
    };
  };
}
