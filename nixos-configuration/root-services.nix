{ config, pkgs, ... }:

{
  services = {
    timesyncd.enable = true; # NTP

    fwupd.enable = true;

    locate = {
      enable = true;
      locate = pkgs.mlocate;
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
      description = "Timer to update NixOS configuration";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 23:30:00";
        Unit = "update-nixos-config.service";
      };
    };
  };
  systemd.services = {
    "update-nixos-config" = {
      description = "Service to update NixOS configuration";
      documentation = [ "man:cp(1)" ];
      script = ''
        set -xeu
        NIXOS_CONFIG_REPO='/home/pratham/my-git-repos/pratham/prathams-nixos'

        if [ "$(id -u)" -ne 0 ]; then
            >&2 echo "$0: please run this script as root"
            exit 1
        fi

        if [ ! -d "$NIXOS_CONFIG_REPO/.git" ]; then
            >&2 echo "$0: '$NIXOS_CONFIG_REPO' does not exist..."
            exit 1
        fi

        cp -fR "$NIXOS_CONFIG_REPO"/nixos-configuration/* /etc/nixos
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
