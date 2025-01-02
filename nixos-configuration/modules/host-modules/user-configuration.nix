{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  systemUserUsername = nixosSystemConfig.coreConfig.systemUser.username;

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
    allowNoPasswordLogin = lib.mkForce false;
    defaultUserShell = pkgs.bashInteractive;
    enforceIdUniqueness = lib.mkForce true;
    mutableUsers = lib.mkForce false; # setting this to `false` means users/groups cannot be added with `useradd`/`groupadd`
    users."root".hashedPassword = "$y$j9T$UWnNglmaKUq7/srkYYfl5/$mPq5GlbqmxRKuOMOYrgEa4O.M48g40OVIB0xpfftZhC";

    groups.${systemUserUsername} = {
      name = systemUserUsername;
      gid = 1000;
    };

    users.${systemUserUsername} = {
      createHome = true;
      description = nixosSystemConfig.coreConfig.systemUser.fullname;
      group = systemUserUsername;
      hashedPassword = nixosSystemConfig.coreConfig.systemUser.hashedPassword;
      home = "/home/${systemUserUsername}";
      isNormalUser = true; # normal vs system is really about a "real" vs "builder" user, respectively
      isSystemUser = false;
      linger = nixosSystemConfig.coreConfig.systemUser.enableLingering or false;
      uid = 1000;
      useDefaultShell = true;

      # Necessary for rootless Podman but no reason to keep it exclusive to it.
      subGidRanges = [{
        startGid = 10000;
        count = 65536;
      }];
      subUidRanges = [{
        startUid = 10000;
        count = 65536;
      }];

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

      # no first password prompt banner "with great power comes great responsibility"
      extraConfig = ''
        Defaults lecture = never
      '';

      extraRules = [{
        users = [ "${systemUserUsername}" ];
        commands = sudoCommands;
      }];
    };
  };
}
