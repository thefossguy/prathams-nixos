{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  useMinimalConfig = config.customOptions.useMinimalConfig;
in
{
  systemd.oomd = {
    enable = true;
    extraConfig = {
      SwapUsedLimit = "75%";
      DefaultMemoryPressureLimit = "50%";
      DefaultMemoryPressureDurationSec = 60;
    };
  };

  services = {
    earlyoom.enable = false;
    fstrim.enable = true;
    fwupd.enable = true;
    journald.storage = "persistent";
    logrotate.enable = true;
    udisks2.enable = true;

    timesyncd = {
      enable = lib.mkForce true; # NTP
      servers = [
        "0.in.pool.ntp.org"
        "1.in.pool.ntp.org"
        "2.in.pool.ntp.org"
        "3.in.pool.ntp.org"
      ];
    };

    locate = lib.attrsets.optionalAttrs (!useMinimalConfig) {
      enable = true;
      package = pkgs.plocate;
      pruneBindMounts = true;

      # The previous `locate = lib.attrsets.optionalAttrs (!useMinimalConfig)`
      # disables mlocate on servers entirely, so this is enabled only on
      # desktops and laptops. Hence the hourly interval.
      interval = "hourly";

      prunePaths = [
        "${config.customOptions.userHomeDir}/.cache"
        "${config.customOptions.userHomeDir}/.dotfiles"
        "${config.customOptions.userHomeDir}/.local/share"
        "${config.customOptions.userHomeDir}/.local/state"
        "${config.customOptions.userHomeDir}/.nix-defexpr"
        "${config.customOptions.userHomeDir}/.nix-profile"
        "${config.customOptions.userHomeDir}/.nvim/undodir"
        "${config.customOptions.userHomeDir}/.prathams-nixos"
        "${config.customOptions.userHomeDir}/.rustup"
        "${config.customOptions.userHomeDir}/.vms"
        "${config.customOptions.userHomeDir}/.zkbd"
        "/nix"
      ];
    };

    openssh = {
      enable = true;
      ports = [ 22 ];
      openFirewall = true;
      authorizedKeysFiles = [ "%h/.ssh/extra_authorized_keys" ];

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
