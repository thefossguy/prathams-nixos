{ config, pkgs, ... }:

{
  services = {
    timesyncd.enable = true; # NTP

    fwupd.enable = true;

    openssh = {
      enable = true;
      extraConfig = "PermitEmptyPasswords no";
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
        X11Forwarding = false;
      };
    };
  };
}
