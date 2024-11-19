{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  userHome = "/home/${nixosSystemConfig.coreConfig.systemUser.username}";
  useMinimalConfig = config.customOptions.useMinimalConfig;
in {

  services = {
    fstrim.enable = true;
    fwupd.enable = true;
    journald.storage = "persistent";
    logrotate.enable = true;
    timesyncd.enable = lib.mkForce true; # NTP
    udisks2.enable = true;

    locate = lib.mkIf (!useMinimalConfig) {
      enable = true;
      localuser = null;
      package = pkgs.mlocate;
      pruneBindMounts = true;

      # Should be `if (nixosSystemConfig.extraConfig.systemType == "server") then "daily" else "hourly"`
      # but the `mkIf (!useMinimalConfig)` disables `locate` for servers.
      interval = "hourly";

      prunePaths = [
        "${userHome}/.cache"
        "${userHome}/.dotfiles"
        "${userHome}/.local/share"
        "${userHome}/.local/state"
        "${userHome}/.nix-defexpr"
        "${userHome}/.nix-profile"
        "${userHome}/.nvim/undodir"
        "${userHome}/.prathams-nixos"
        "${userHome}/.rustup"
        "${userHome}/.vms"
        "${userHome}/.zkbd"
        "/nix"
      ];
    };

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
