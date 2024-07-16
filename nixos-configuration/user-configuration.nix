{ pkgs, systemUser, ... }:

let
  sudoRules = with pkgs; [
    { package = coreutils; command = "sync"; }
    { package = hdparm; command = "hdparm"; }
    { package = nix; command = "nix-collect-garbage"; }
    { package = nixos-rebuild; command = "nixos-rebuild"; }
    { package = nvme-cli; command = "nvme"; }
    { package = systemd; command = "poweroff"; }
    { package = systemd; command = "reboot"; }
    { package = systemd; command = "shutdown"; }
    { package = systemd; command = "systemctl"; }
    { package = util-linux; command = "dmesg"; }
  ];

  mkSudoRule = rule: {
    command = "${rule.package}/bin/${rule.command}";
    options = [ "NOPASSWD" ];
  };

  sudoCommands = map mkSudoRule sudoRules;

in {
  users = {
    allowNoPasswordLogin = false;
    defaultUserShell = pkgs.bash;
    enforceIdUniqueness = true;
    mutableUsers = false; # setting this to `false` means users/groups cannot be added with `useradd`/`groupadd`

    groups.${systemUser.username} = {
      name = "${systemUser.username}";
      gid = 1000;
    };

    users.${systemUser.username} = {
      createHome = true;
      description = "${systemUser.fullname}";
      group = "${systemUser.username}";
      hashedPassword = "${systemUser.hashedPassword}";
      home = "/home/${systemUser.username}";
      isNormalUser = true; # normal vs system is really about a "real" vs "builder" user, respectively
      isSystemUser = false;
      linger = systemUser.enableLingering or false;
      subGidRanges = [{ startGid = 10000; count = 65536; }];
      subUidRanges = [{ startUid = 10000; count = 65536; }];
      uid = 1000;
      useDefaultShell = true;

      extraGroups = [
        "adbusers"
        "adm"
        "audio"
        "dialout"
        "ftp"
        "games"
        "http"
        "kvm"
        "libvirt"
        "libvirtd"
        "log"
        "mlocate"
        "networkmanager"
        "podman"
        "qemu-libvirtd"
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

  security = {
    polkit.enable = true;

    sudo = {
      enable = true;
      execWheelOnly = true;
      keepTerminfo = true;
      wheelNeedsPassword = true;

      extraRules = [{
        users = [ "${systemUser.username}" ];
        commands = sudoCommands;
      }];
    };
  };
}
