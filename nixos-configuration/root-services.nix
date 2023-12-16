{ config, pkgs, ... }:

{
  services = {
    timesyncd.enable = true; # NTP

    fwupd.enable = true;

    locate = {
      enable = true;
      package = pkgs.mlocate;
      localuser = null;
      interval = "daily";
      prunePaths = [ "/nix/store" ];
    };

    openssh = {
      enable = true;
      extraConfig = "PermitEmptyPasswords no";
      ports = [ 22 ];
      openFirewall = true;
      settings = {
        Protocol = 2;
        MaxAuthTries = 2;
        PermitEmptyPasswords = false;
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
        X11Forwarding = false;
      };
    };
  };

  systemd.timers = {
    "update-nixos-config" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 23:30:00";
        Unit = "update-nixos-config.service";
      };
    };
  };
  systemd.services = {
    "update-nixos-config" = {
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${pkgs.coreutils}/bin/cp -fR /home/pratham/my-git-repos/pratham/prathams-nixos/nixos-configuration/. /etc/nixos";
      };
    };
  };
}
