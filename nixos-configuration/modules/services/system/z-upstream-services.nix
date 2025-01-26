{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  userHome = "/home/${nixosSystemConfig.coreConfig.systemUser.username}";
  useMinimalConfig = config.customOptions.useMinimalConfig;
in
{
  systemd.oomd.enable = true;
  services = {
    earlyoom.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;
    journald.storage = "persistent";
    logrotate.enable = true;
    timesyncd.enable = lib.mkForce true; # NTP
    udisks2.enable = true;

    locate = lib.attrsets.optionalAttrs (!useMinimalConfig) {
      enable = true;
      localuser = null;
      package = pkgs.mlocate;
      pruneBindMounts = true;

      # The previous `locate = lib.attrsets.optionalAttrs (!useMinimalConfig)`
      # disables mlocate on servers entirely, so this is enabled only on
      # desktops and laptops. Hence the hourly interval.
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
        MaxAuthTries = lib.mkForce 10;
        PasswordAuthentication = lib.mkForce false;
        PermitEmptyPasswords = lib.mkForce false;
        PermitRootLogin = lib.mkForce "prohibit-password";
        Protocol = lib.mkForce 2;
        X11Forwarding = lib.mkForce false;
      };
    };
  };
}
