{ config
, lib
, pkgs
, systemUser
, ...
}:

let
  userHome = "/home/${systemUser.username}";
in

{
  services = {
    fwupd.enable = true;
    journald.storage = "persistent";
    logrotate.enable = true;
    timesyncd.enable = true; # NTP
    udisks2.enable = true;

    locate = {
      enable = true;
      interval = "hourly";
      localuser = null;
      package = pkgs.mlocate;
      pruneBindMounts = true;

      prunePaths = [
        "${userHome}/.cache"
        "${userHome}/.dotfiles"
        "${userHome}/.local/share"
        "${userHome}/.local/state"
        "${userHome}/.nix-defexpr"
        "${userHome}/.nix-profile"
        "${userHome}/.nvim/undodir"
        "${userHome}/.rustup"
        "${userHome}/.vms"
        "${userHome}/.zkbd"
        "/nix"
      ];
    };

    # sshd_config
    openssh = {
      enable = true;
      ports = [ 22 ];
      openFirewall = true;

      settings = {
        Protocol = 2;
        MaxAuthTries = 2;
        PermitEmptyPasswords = lib.mkForce false;
        PasswordAuthentication = lib.mkForce false;
        PermitRootLogin = lib.mkForce "prohibit-password";
        X11Forwarding = false;
      };
    };
  };

  # custom upgrade service+timer
  systemd.services = {
    update-my-nixos = {
      enable = true;
      script = ''
        set -xeuf -o pipefail

        NIXOS_CONFIG_PATH='/root/nixos-config'
        export PATH="$PATH:${pkgs.openssh}/bin:${pkgs.openssl}/bin"

        if [[ ! -d "$NIXOS_CONFIG_PATH" ]]; then
            ${pkgs.git}/bin/git clone https://gitlab.com/thefossguy/prathams-nixos $NIXOS_CONFIG_PATH
        fi

        pushd $NIXOS_CONFIG_PATH
        ${pkgs.nix}/bin/nix flake update
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --show-trace --flake ".#$(hostname)"
        popd
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
  systemd.timers = {
    update-my-nixos = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        Unit = "update-my-nixos.service";
        OnCalendar = "hourly";
      };
    };
  };
}
