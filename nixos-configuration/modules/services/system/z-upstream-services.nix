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
      ports = [ (if config.customOptions.useAlternativeSSHPort then 6922 else 22) ];
      openFirewall = true;
      authorizedKeysFiles = [ "%h/.ssh/extra_authorized_keys" ];

      settings = {
        AllowAgentForwarding = lib.mkForce false;
        AllowTcpForwarding = lib.mkForce false;
        AuthenticationMethods = lib.mkForce "publickey";
        Banner = lib.mkForce false;
        ChallengeResponseAuthentication = lib.mkForce false;
        GSSAPIAuthentication = lib.mkForce false;
        KbdInteractiveAuthentication = lib.mkForce false;
        KerberosAuthentication = lib.mkForce false;
        LoginGraceTime = 0; # CVE-2024-6387 “regreSSHion”
        MaxAuthTries = lib.mkForce 10;
        PasswordAuthentication = lib.mkForce false;
        PermitEmptyPasswords = lib.mkForce false;
        PermitRootLogin = lib.mkForce "prohibit-password";
        PermitTunnel = lib.mkForce false;
        PermitUserEnvironment = lib.mkForce false;
        Protocol = lib.mkForce 2;
        PubkeyAuthentication = lib.mkForce true;
        X11Forwarding = lib.mkForce false;

        # `journalctl -b 0 -xeu sshd | grep Invalid\ user | awk '{print $8}' | sort | uniq`
        DenyUsers = [
          "admin"
          "antoine"
          "apache2"
          "client"
          "cron"
          "dataiku"
          "db_backup"
          "dbadmin"
          "dhcp"
          "ernanir"
          "fgu"
          "ftp"
          "galdanf"
          "h"
          "informes"
          "ioana"
          "jeff"
          "jocelyn"
          "kimmel"
          "kms"
          "michael"
          "mlmb"
          "myk"
          "pokemongo"
          "postgres"
          "pradeep"
          "qody"
          "reboot"
          "redmine"
          "sinus"
          "stones"
          "susann"
          "temp"
          "test"
          "upload"
          "user"
          "user1"
          "vip"
          "virginia"
          "yamaha"
        ];
      };
    };
  };
}
