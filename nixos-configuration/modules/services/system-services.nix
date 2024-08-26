{ config, lib, pkgs, systemUser, ... }:

let userHome = "/home/${systemUser.username}";
in {
  imports = [
    ./custom-nixos-upgrade.nix
    ./ensure-local-static-ip.nix
    ./needs-reboot.nix
    ./update-nixos-flake-inputs.nix
  ];

  services.logrotate = {
    enable = true;
    # With the hardened linux kernel, the config check for logrotate fails at build-time
    # but since you can't disable `unprivileged_userns_clone`, disable the check instead
    # https://discourse.nixos.org/t/logrotate-config-fails-due-to-missing-group-30000/28501/9
    checkConfig = !config.boot.kernelPackages.kernel.isHardened;
  };

  services = {
    fwupd.enable = true;
    journald.storage = "persistent";
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
        LoginGraceTime = 0; # CVE-2024-6387 “regreSSHion”
        MaxAuthTries = 2;
        PasswordAuthentication = lib.mkForce false;
        PermitEmptyPasswords = lib.mkForce false;
        PermitRootLogin = lib.mkForce "prohibit-password";
        Protocol = 2;
        X11Forwarding = false;
      };
    };
  };
}
