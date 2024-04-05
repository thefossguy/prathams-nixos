{ lib, pkgs, ... }:

let
  NixOSRelease = "23.11";
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-${NixOSRelease}.tar.gz";
  prathamsHome = "/home/pratham";
  scriptsDir = "${prathamsHome}/.local/scripts";

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

  whatIGetForSupportingTheRaspberryPiFoundation = pkgs.writeShellScriptBin "populate-boot-for-raspberry-pi" ''
    set -xe

    if grep 'Raspberry Pi' /proc/device-tree/model > /dev/null; then
        cp "${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin" /boot
        cp -r "${pkgs.raspberrypifw}/share/raspberrypi/boot/"* /boot
        cat << EOF > /boot/config.txt
        enable_uart=1
        avoid_warnings=1
        arm_64bit=1
        kernel=u-boot.bin
        [pi4]
        #hdmi_enable_4kp60=1
        arm_boost=1
    fi
  '';

  OVMFBinName = if pkgs.stdenv.isAarch64 then "AAVMF"
    else (
      if pkgs.stdenv.isx86_64 then "OVMF"
      else ""
    );
in

{
  imports = [
    ./host-specific-configuration.nix # specific to this host
    (import "${home-manager}/nixos") # aye, home-manager
    ./hardware-configuration.nix # generated by 'nixos-generate-config'
  ];

  # {{ packages section }}
  nixpkgs.config.allowUnfree = true; # allow non-FOSS pkgs

  # {{ user configuration }}
  users = {
    allowNoPasswordLogin = false;
    defaultUserShell = pkgs.bash;
    enforceIdUniqueness = true;
    mutableUsers = false; # setting this to `false` means users/groups cannot be added with `useradd`/`groupadd`

    users.root.hashedPassword = "$6$cxSzljtGpFNLRhx1$0HvOs4faEzUw9FYUF8ifOwBPwHsGVL7HenQMCOBNwqknBFHSlA6NIDO7U36HeQ/C9FN/B.dP.WBg3MzqQcubr0";

    users.pratham = {
      createHome = true;
      description = "Pratham Patel";
      group = "pratham";
      hashedPassword = "$6$QLxAJcAeYARWFnnh$MaicewslNWkf/D8o6lDAWA1ECLMZLL3KWgIqPKuu/Qgt3iDBCEbEFjt3CUI4ENifvXW/blpze8IYeWhDjaKgS1";
      home = "${prathamsHome}";
      isNormalUser = true; # normal vs system is really about a "real" vs "builder" user, respectively
      isSystemUser = false;
      linger = true;
      subGidRanges = [ { startGid = 10000; count = 65536; } ];
      subUidRanges = [ { startUid = 10000; count = 65536; } ];
      uid = 1000;

      extraGroups = [
        "adbusers"
        "adm"
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
    groups.pratham = {
      name = "pratham";
      gid = 1000;
    };
  };

  # {{ sudo configuration }}
  security.sudo = {
    enable = true;
    execWheelOnly = true;
    keepTerminfo = true;
    wheelNeedsPassword = true;
    extraRules = [{
      users = [ "pratham" ];
      commands = sudoCommands;
    }];
  };

  # {{ home-manager configuration }}
  # call the home-manager configuration directly
  # without having to depend on a $HOME/.config/home-manager/{home,flake}.nix
  home-manager.users.pratham = { lib, pkgs, ... }: {
    home.stateVersion = "${NixOSRelease}";
    programs = {
      aria2.enable = true;
      bat.enable = true;
      bottom.enable = true;
      broot.enable = true;
      btop.enable = true;
      ripgrep.enable = true;
      tealdeer.enable = true;
      yt-dlp.enable = true;
      zoxide.enable = true;

      direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };

      neovim = {
        enable = true;
        extraPackages = with pkgs; [
          clang-tools # provides clangd
          gcc # for nvim-tree's parsers
          lldb # provides lldb-vscode
          lua-language-server
          nil # language server for Nix
          nixpkgs-fmt
          nodePackages.bash-language-server
          ruff
          shellcheck
          tree-sitter # otherwise nvim complains that the binary 'tree-sitter' is not found
        ];
      };
    };

    # for raw QEMU VMs
    home.activation = {
      OVMFActivation = lib.hm.dag.entryAfter [ "installPackages" ] (if pkgs.stdenv.isx86_64 then ''
          EDKII_CODE_NIX="${pkgs.OVMF}/FV/${OVMFBinName}_CODE.fd"
          EDKII_VARS_NIX="${pkgs.OVMF}/FV/${OVMFBinName}_VARS.fd"

          EDKII_DIR_HOME="$HOME/.local/share/edk2"
          EDKII_CODE_HOME="$EDKII_DIR_HOME/EDKII_CODE"
          EDKII_VARS_HOME="$EDKII_DIR_HOME/EDKII_VARS"

          if [ -d "$EDKII_DIR_HOME" ]; then
              rm -rf "$EDKII_DIR_HOME"
          fi
          mkdir -vp "$EDKII_DIR_HOME"

          cp "$EDKII_CODE_NIX" "$EDKII_CODE_HOME"
          cp "$EDKII_VARS_NIX" "$EDKII_VARS_HOME"

          chown pratham:pratham "$EDKII_CODE_HOME" "$EDKII_VARS_HOME"
          chmod 644 "$EDKII_CODE_HOME" "$EDKII_VARS_HOME"
        '' else "");
    };

    # for libvirt, virt-manager, virsh
    xdg.configFile = {
      "libvirt/qemu.conf" = {
        enable = true;
        text = ''
          nvram = [ "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd", "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
        '';
      };
    };
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };

    systemd.user.services = {
      "dotfiles-pull" = {
        Unit = {
          Description = "Pull dotfiles";
        };
        Service = {
          ExecStart = "${pkgs.dash}/bin/dash ${scriptsDir}/other-common-scripts/dotfiles-pull.sh";
          Environment = [ "\"PATH=${pkgs.git}/bin:${pkgs.openssh}/bin\"" ];
          Type = "oneshot";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      "flatpak-manage" = {
        Unit = {
          Description = "Manage flatpaks on system";
        };
        Service = {
          ExecStart = "${pkgs.bash}/bin/bash ${scriptsDir}/other-common-scripts/flatpak-manage.sh";
          Environment = [ "\"PATH=${pkgs.gnugrep}/bin\"" ];
          Type = "oneshot";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      "nixos-config-pull" = {
        Unit = {
          Description = "Pull NixOS configuration";
        };
        Service = {
          ExecStart = "${pkgs.dash}/bin/dash ${scriptsDir}/nixos/nixos-config-pull.sh";
          Environment = [ "\"PATH=${pkgs.git}/bin:${pkgs.openssh}/bin\"" ];
          Type = "oneshot";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };

      "update-rust" = {
        Unit = {
          Description = "Upgrade the Rust toolchain";
        };
        Service = {
          ExecStart = "${pkgs.dash}/bin/dash ${scriptsDir}/other-common-scripts/rust-manage.sh";
          Environment = [ "\"PATH=${pkgs.procps}/bin:${pkgs.rustup}/bin\"" ];
          Type = "oneshot";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };

    systemd.user.timers = {
      "dotfiles-pull" = {
        Unit = {
        };
        Timer = {
          OnCalendar = "*-*-* 23:00:00";
          Unit = "dotfiles-pull.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };

      "flatpak-manage" = {
        Unit = {
        };
        Timer = {
          OnBootSec = "now";
          OnCalendar = "Mon *-*-* 04:00:00";
          Unit = "flatpak-manage.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };

      "nixos-config-pull" = {
        Unit = {
        };
        Timer = {
          OnCalendar = "*-*-* 23:00:00";
          Unit = "nixos-config-pull.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };

      "update-rust" = {
        Unit = {
        };
        Timer = {
          OnBootSec = "now";
          OnCalendar = "Mon *-*-* 04:00:00";
          Unit = "update-rust.service";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };

  # {{ system services' "parameters" go here }}
  environment.etc."resolv.conf".mode = "direct-symlink";
  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

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
        "${prathamsHome}/.cache"
        "${prathamsHome}/.dotfiles"
        "${prathamsHome}/.local/share"
        "${prathamsHome}/.local/state"
        "${prathamsHome}/.nix-defexpr"
        "${prathamsHome}/.nix-profile"
        "${prathamsHome}/.nvim/undodir"
        "${prathamsHome}/.rustup"
        "${prathamsHome}/.vms"
        "${prathamsHome}/.zkbd"
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

  systemd.timers = {
    "update-nixos-config" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 23:30:00";
        Unit = "update-nixos-config.service";
      };
    };
  };
  systemd.services = {
    "update-nixos-config" = {
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${pkgs.coreutils}/bin/cp -fR ${prathamsHome}/my-git-repos/pratham/prathams-nixos/nixos-configuration/. /etc/nixos";
      };
    };
  };

  # {{ configuration options related to Nix and NixOS }}
  nix = {
    gc = {
      automatic = true;
      dates = "*-*-* 23:00:00"; # everyday, at 23:00
      options = "--delete-older-than 14d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      keep-going = false;
      log-lines = 9999;
      sandbox = true;
      show-trace = true;
      trusted-users = [ "root" "pratham" ];
    };
  };

  system = {
    stateVersion = "${NixOSRelease}"; # release version of NixOS
    # TODO: after adding `ubootRaspberryPi_64bit` to nixpkgs
    # also remove: `scripts/{get-raspi-4-firmware,raspberry-pi-partitions}.sh`
    #build.separateActivationScript = "${whatIGetForSupportingTheRaspberryPiFoundation}/bin/populate-boot-for-raspberry-pi";

    autoUpgrade = {
      enable = true;
      dates = "daily"; # *-*-* 00:00:00
      allowReboot = false;
      operation = "boot";
      persistent = true;
    };
  };

  # {{ networking section }}
  systemd.network = {
    enable = true;
    wait-online = {
      enable = true;
      anyInterface = true;
    };
  };

  networking = {
    firewall.enable = false; # this uses iptables AFAIK, use nftables instead
    networkmanager.enable = true;
    nftables.enable = true;
    wireless.enable = false; # this enabled 'wpa_supplicant', use networkmanager instead
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  # {{ misc }}
  time = {
    timeZone = "Asia/Kolkata";
    hardwareClockInLocalTime = true;
  };

  security = {
    polkit.enable = true;
    virtualisation.flushL1DataCache = "always";
  };

  console = {
    enable = true;
    earlySetup = true;
  };

  # {{ environment... stuff }}
  i18n = {
    defaultLocale = "en_IN";
    extraLocaleSettings = {
      LC_ADDRESS = "en_IN";
      LC_IDENTIFICATION = "en_IN";
      LC_MEASUREMENT = "en_IN";
      LC_MONETARY = "en_IN";
      LC_NAME = "en_IN";
      LC_NUMERIC = "en_IN";
      LC_PAPER = "en_IN";
      LC_TELEPHONE = "en_IN";
      LC_TIME = "en_IN";
    };
  };

  environment = {
    homeBinInPath = true;
    localBinInPath = true;
    variables = {
      # for 'sudo -e'
      EDITOR = "nvim";
      VISUAL = "nvim";
      # systemd
      SYSTEMD_PAGER = "";
      SYSTEMD_EDITOR = "nvim";
      TERM = "xterm-256color";
      # set locale manually because even though NixOS handles the 'en_IN' locale
      # it doesn't append the string '.UTF-8' to LC_*
      # but, UTF-8 **is supported**, so just go ahead and set it manually
      LANG = lib.mkDefault "en_IN.UTF-8";
      LC_ADDRESS = lib.mkDefault "en_IN.UTF-8";
      LC_COLLATE = "en_IN.UTF-8";
      LC_CTYPE = "en_IN.UTF-8";
      LC_IDENTIFICATION = lib.mkDefault "en_IN.UTF-8";
      LC_MEASUREMENT = lib.mkDefault "en_IN.UTF-8";
      LC_MESSAGES = "en_IN.UTF-8";
      LC_MONETARY = lib.mkDefault "en_IN.UTF-8";
      LC_NAME = lib.mkDefault "en_IN.UTF-8";
      LC_NUMERIC = lib.mkDefault "en_IN.UTF-8";
      LC_PAPER = lib.mkDefault "en_IN.UTF-8";
      LC_TELEPHONE = lib.mkDefault "en_IN.UTF-8";
      LC_TIME = lib.mkDefault "en_IN.UTF-8";
      LC_ALL = "";
      # idk why, but some XDG vars aren't set, the missing ones are now set according to the
      # spec: (https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_CACHE_HOME = "$HOME/.cache";
    };
  };

  # yes, I want docs
  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
  };

  # {{ virtualisation and container settings }}
  virtualisation = {
    oci-containers.backend = "podman";

    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
      allowedBridges = [ "virbr0" ];
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false; # not sure about this
        swtpm.enable = true;

        ovmf = {
          enable = true;
          packages = [ pkgs.OVMF ];
        };

        verbatimConfig = ''
          user = "pratham"
          group = "pratham"
        '';
      };
    };

    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      networkSocket.openFirewall = true;
      extraPackages = [ pkgs.buildah ];
      defaultNetwork.settings = {
        dns_enabled = true;
      };
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };
  };

  boot = {
    kernelParams = [
      "audit=0"
      "ignore_loglevel"

      "boot.shell_on_fail"

      "fsck.mode=auto"
      "fsck.repair=preen"

      "plymouth.enable=0"
      "rd.plymouth=0"

      "no_console_suspend"
    ];

    supportedFilesystems = [
      "ext4"
      "f2fs"
      "vfat"
      "xfs"
    ];

    kernel.sysctl = {
      ## Z-RAM-Swap
      # Kernel docs: https://docs.kernel.org/admin-guide/sysctl/vm.html
      # Pop!_OS "docs": https://github.com/pop-os/default-settings/pull/163/files
      # Using zramswap, penalty shouldn't be that high, since if you are under
      # high memory pressure, you likely are under high CPU load too
      # at which point, you are performing computations and latency goes moot.
      "vm.swappiness" = 180;
      # Since zramSwap.algorithm is set to 'zstd', it is recommeded to set the
      # 'vm.page-cluster' paramater to '0'.
      "vm.page-cluster" = 0;
      # Ensure that at-least 512MBytes of total memory is free to avoid system freeze.
      # Not sure about the 512MBytes value since Pop!_OS sets it to 0.01% of total memory,
      # which is roughly equal to 3.7MBytes on a 3700MBytes RPi4. The value of 512MBytes
      # also does not leave lee-way for a 512M RPi Zero.
      # A value too LOW  will result in system freeze.
      # A value too HIGH will result in OOM faster.
      "vm.min_free_kbytes"= 512000;
      # Disable 'vm.wwatermark_scale_factoratermark_boost_factor'.
      # https://groups.google.com/g/linux.debian.user/c/YcDYu-jM-to
      "vm.watermark_boost_factor" = 0;
      # Start swapping when 70% of memory is full (30% of memory is left).
      # 3000 is the MAX
      "vm.watermark_scale_factor" = 3000;
      # Increase the number of maximum mmaps a process may have (ZFS).
      # 2147483642 = 1.99-ish GiB
      "vm.max_map_count" = 2147483642;

      # Same as `vm.dirty_ratio` but for background tasks
      "vm.dirty_background_ratio" = 10;
      # After how many centiseconds (1 second = 100 centiseconds) is dirty data
      # committed to the disk
      "vm.dirty_expire_centisecs" = 3000;
      # Percentage of memory allowed to be filled with dirty data until it is
      # committed to the disk
      "vm.dirty_ratio" = 20;
      # Interval between the kernel flusher threads that wake up to write old
      # data to the disk. **Try keeping this less than half of whatever
      # `vm.dirty_expire_centisecs`.**
      # Check every N centisecs if data needs to be committed to the disk or not.
      "vm.dirty_writeback_centisecs" = 1000;

      # The Magic SysRq key is a key combo that allows users connected to the
      # system console of a Linux kernel to perform some low-level commands.
      # Disable it, since we don't need it, and is a potential security concern.
      "kernel.sysrq" = 0;

      ## TCP hardening
      # Prevent bogus ICMP errors from filling up logs.
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Reverse path filtering causes the kernel to do source validation of
      # packets received from all interfaces. This can mitigate IP spoofing.
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      # Do not accept IP source route packets (we're not a router)
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      # Don't send ICMP redirects (again, we're on a router)
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      # Refuse ICMP redirects (MITM mitigations)
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      # Protects against SYN flood attacks
      "net.ipv4.tcp_syncookies" = 1;
      # Incomplete protection again TIME-WAIT assassination
      "net.ipv4.tcp_rfc1337" = 1;

      ## TCP optimization
      # TCP Fast Open is a TCP extension that reduces network latency by packing
      # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
      # both incoming and outgoing connections:
      "net.ipv4.tcp_fastopen" = 3;
      # Bufferbloat mitigations + slight improvement in throughput & latency
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";

      ## Allow rootless containers to get pinged and/or ping each other
      "net.ipv4.ping_group_range" = "0 165536";
    };

    loader = {
      timeout = 5;
      systemd-boot = {
        enable = true;
        editor = false;
      };
    };
  };

  hardware.enableRedistributableFirmware = true;
}
