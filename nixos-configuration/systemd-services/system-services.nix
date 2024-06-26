{ lib, pkgs, systemUser, ... }:

let userHome = "/home/${systemUser.username}";

in {
  imports = [
   ./custom-nixos-upgrade.nix
   ./ensure-local-static-ip.nix
   ./needs-reboot.nix
   ];

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
}
