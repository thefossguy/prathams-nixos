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
  imports = [ ./nixos-update-and-upgrade.nix ];

  services = {
    fwupd.enable = true;
    journald.storage = "persistent";
    logrotate.enable = true;
    timesyncd.enable = true; # NTP
    udisks2.enable = true;
    #nixos-needsreboot.enable = true; # TODO: after it gets merged in 24.05/24.11

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
