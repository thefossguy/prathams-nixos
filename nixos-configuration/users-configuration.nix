{ pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
in

{
  imports = [ (import "${home-manager}/nixos") ];

  users = {
    # do not allow any more users on the system than what is defined here
    mutableUsers = false;
    allowNoPasswordLogin = false;
    defaultUserShell = pkgs.bash;
    enforceIdUniqueness = true;

    users = {
      root = {
        hashedPassword = "$6$cxSzljtGpFNLRhx1$0HvOs4faEzUw9FYUF8ifOwBPwHsGVL7HenQMCOBNwqknBFHSlA6NIDO7U36HeQ/C9FN/B.dP.WBg3MzqQcubr0";
      };
      pratham = {
        isNormalUser = true;
        description = "Pratham Patel";
        createHome = true;
        home = "/home/pratham";
        group = "pratham";
        uid = 1000;
        subUidRanges = [ { startUid = 10000; count = 65536; } ];
        subGidRanges = [ { startGid = 10000; count = 65536; } ];
        #linger = true; # 23.11 and later; remove 'systemd.tmpfiles.rules'
        hashedPassword = "$6$QLxAJcAeYARWFnnh$MaicewslNWkf/D8o6lDAWA1ECLMZLL3KWgIqPKuu/Qgt3iDBCEbEFjt3CUI4ENifvXW/blpze8IYeWhDjaKgS1";
        extraGroups = [
          "adm"
          "dialout"
          "ftp"
          "games"
          "http"
          "kvm"
          "libvirt"
          "libvirtd"
          "log"
          "networkmanager"
          "podman"
          "rfkill"
          "sshusers"
          "sys"
          "systemd-journal"
          "uucp"
          "video"
          "wheel"
          "zfs-read"
        ];
      };
    };
    groups.pratham = {
      name = "pratham";
      gid = 1000;
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
    extraRules = [{
      users = [ "pratham" ];
      commands = [
        {
          command = "${pkgs.util-linux}/bin/dmesg";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.nix}/bin/nix-collect-garbage";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.hdparm}/bin/hdparm";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.nvme-cli}/bin/nvme";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/poweroff";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/shutdown";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.coreutils}/bin/sync";
          options = [ "NOPASSWD" ];
        }
        #{
        #  command = "ALL";
        #  options = [ "NOPASSWD" ];
        #}
      ];
    }];
  };

  # temporary hack until official lingering support is added to `users.users`
  systemd.tmpfiles.rules = [
    "f /var/lib/systemd/linger/pratham"
  ];

  home-manager.users.pratham = { pkgs, ... }: {
    home.stateVersion = "23.11";
    programs.nix-index = {
      enable = true;
      enableBashIntegration = true;
    };
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
    };
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
