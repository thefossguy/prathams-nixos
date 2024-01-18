{ lib, pkgs, ... }:

let
  NixOSRelease = "23.11";
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-${NixOSRelease}.tar.gz";
in

{
  imports = [
    # generated by 'nixos-generate-config'
    ./hardware-configuration.nix

    # aye, home-manager
    (import "${home-manager}/nixos")

    # specific to this host
    ./host-specific-configuration.nix

    # user services
    ./user-services/services-master.nix
  ];

  nixpkgs.config.allowUnfree = true; # allow non-FOSS pkgs
  system = {
    stateVersion = "${NixOSRelease}"; # release version of NixOS

    autoUpgrade = {
      enable = true;
      dates = "daily"; # *-*-* 00:00:00
      allowReboot = false;
      operation = "boot";
      persistent = true;
    };
  };

  # packages to be installed _system wide_
  environment.systemPackages = with pkgs; [
    # base system packages + packages what I *need*
    cloud-utils # provides growpart
    coreutils
    dmidecode
    doas
    file
    findutils
    gawk
    gettext # for translation (human lang; Eng <-> Hindi)
    gnugrep
    gnused
    hdparm
    inotify-tools
    iproute
    iputils
    linux-firmware
    lsof
    mlocate
    nvme-cli
    openssh
    openssl
    parallel
    pciutils # provides lspci and setpci
    pinentry # pkg summary: GnuPG’s interface to passphrase input
    procps # provides pgrep, kill, watch, ps, pidof, uptime, sysctl, free, etc
    psmisc # provides killall, fuser, pslog, pstree, etc
    pv
    python3Minimal
    rsync
    shadow
    smartmontools
    tmux
    tree
    usbutils
    util-linux # provides blkid, losetup, lsblk, rfkill, fallocate, dmesg, etc
    wol

    # text editors
    nano
    vim

    # shells
    dash

    # download clients
    aria2
    curl
    wget
    yt-dlp

    # compression and decompression
    bzip2
    gnutar
    gzip
    #rar # absent on aarch64, and not really needed
    unzip
    xz
    zip
    zstd

    # programming tools + compilers
    #cargo-deb # generate .deb packages solely based on Cargo.toml
    #cargo-ndk # extension for building Android NDK projects
    b4 # applying patches from mailing lists
    binutils # provides readelf, objdump, strip, as, objcopy (GNU; not LLVM)
    cargo-audit # audit crates for security vulnerabilities
    cargo-benchcmp # compare Rust micro-benchmarks
    cargo-binstall # install Rust binaries instead of building them from src
    cargo-bisect-rustc # find exactly which rustc commit/release-version which prevents your code from building now
    cargo-bloat # find what takes the most space in the executable
    cargo-cache # manage cargo cache (${CARGO_HOME}); print and remove dirs selectively
    cargo-chef # for speeding up container builds using layer caching
    cargo-deps # build dependency graph of Rust projects
    cargo-dist # distribute on crates.io
    cargo-flamegraph # flamegraphs without Perl or pipes
    cargo-hack # build project with all the possible variations of options/flags and check which ones fail and/or succeed
    cargo-outdated # show outdated deps
    cargo-profiler # profile Rust binaries
    cargo-public-api # detect breaking API changes and semver violations
    cargo-show-asm # display ASM, LLVM-IR, MIR and WASM for the Rust src
    cargo-sweep # cleanup unused build files
    cargo-udeps # find unused dependencies
    cargo-update # update installed binaries
    cargo-valgrind
    cargo-vet # ensure that the third-party dependencies are audited by a trusted source
    cargo-watch # run cargo commands when the src changes
    gcc
    rustup # provides rustfmt, cargo-clippy, rustup, cargo, rust-lldb, rust-analyzer, rustc, rust-gdb, cargo-fmt

    # language servers, parsers and other related packages
    clang-tools # provides clangd
    lldb # provides lldb-vscode
    lua-language-server
    nil # language server for Nix
    nodePackages.bash-language-server
    ruff
    shellcheck
    tree-sitter # otherwise nvim complains that the binary 'tree-sitter' is not found

    # power management
    acpi
    lm_sensors

    # dealing with other distro's packages
    dpkg
    rpm

    # for media consumption, manipulation and metadata info
    ffmpeg
    imagemagick
    mediainfo

    # system monitoring
    btop
    htop

    # network monitoring
    iperf # this is iperf3
    iperf2 # this is what is usually 'iperf' on other distros
    nload

    # other utilities
    asciinema
    buildah
    fzf
    parted
    picocom
    ubootTools
    ventoy

    # utilities written in Rust
    bat
    bottom
    broot
    choose
    du-dust
    dua
    fd
    hyperfine
    procs
    ripgrep
    sd
    skim
    tealdeer
    tre-command
    zoxide

    # virtualisation
    #OVMF
    #qemu
    #qemu-utils
    qemu_kvm

    # tools specific to NixOS
    nix-output-monitor
    nvd # diff between NixOS generations
  ];

  programs = {
    adb.enable = true;
    bash = {
      enableCompletion = true;
      # notifications when long-running terminal commands complete
      undistractMe = {
        enable = true;
        playSound = true;
        timeout = 60; # notify only if said command has been running for this many seconds
      };
    };
    bandwhich.enable = true;
    ccache.enable = true;
    command-not-found.enable = true;
    dconf.enable = true;
    git.enable = true;
    gnupg.agent.enable = true;
    iotop.enable = true;
    mtr.enable = true;
    neovim.enable = true;
    sniffnet.enable = true;
    usbtop.enable = true;
  };

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
        linger = true;
        hashedPassword = "$6$QLxAJcAeYARWFnnh$MaicewslNWkf/D8o6lDAWA1ECLMZLL3KWgIqPKuu/Qgt3iDBCEbEFjt3CUI4ENifvXW/blpze8IYeWhDjaKgS1";
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

  home-manager.users.pratham = { pkgs, ... }: {
    home.stateVersion = "${NixOSRelease}";
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

    systemd.user.services = {
      "dotfiles-pull" = {
        Unit = {
          Description = "Pull dotfiles";
        };
        Service = {
          ExecStart = "${pkgs.dash}/bin/dash /home/pratham/.local/scripts/other-common-scripts/dotfiles-pull.sh";
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
          ExecStart = "${pkgs.bash}/bin/bash /home/pratham/.local/scripts/other-common-scripts/flatpak-manage.sh";
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
          ExecStart = "${pkgs.dash}/bin/dash /home/pratham/.local/scripts/nixos/nixos-config-pull.sh";
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
          ExecStart = "${pkgs.dash}/bin/dash /home/pratham/.local/scripts/other-common-scripts/rust-manage.sh";
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

  services = {
    fwupd.enable = true;
    journald.storage = "persistent";
    logrotate.enable = true;
    timesyncd.enable = true; # NTP
    udisks2.enable = true;

    locate = {
      enable = true;
      package = pkgs.mlocate;
      localuser = null;
      interval = "daily";
      prunePaths = [ "/nix/store" ];
    };

    openssh = {
      enable = true;
      extraConfig = "PermitEmptyPasswords no";
      ports = [ 22 ];
      openFirewall = true;
      settings = {
        Protocol = 2;
        MaxAuthTries = 2;
        PermitEmptyPasswords = false;
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
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
        ExecStart = "${pkgs.coreutils}/bin/cp -fR /home/pratham/my-git-repos/pratham/prathams-nixos/nixos-configuration/. /etc/nixos";
      };
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "Sun *-*-* 00:00:00";
      options = "--delete-older-than 14d";
    };
    settings = {
      trusted-users = [ "root" "pratham" ];
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  systemd.network.wait-online = {
    enable = true;
    anyInterface = true;
  };

  networking = {
    networkmanager.enable = true;
    wireless.enable = false;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    firewall = {
      enable = true;
      allowPing = true;
      #allowedTCPPorts = [];
      #allowedUDPPorts = [];
    };
  };

  time = {
    timeZone = "Asia/Kolkata";
    hardwareClockInLocalTime = true;
  };

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

  security = {
    polkit.enable = true;
    #virtualisation.flushL1DataCache = true;
  };

  console = {
    enable = true;
    earlySetup = true;
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

  virtualisation = {
    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
      allowedBridges = [ "virbr0" ];
      qemu = {
        runAsRoot = false; # not sure about this
        verbatimConfig = ''
        user = "pratham"
        group = "pratham"
        '';
      };
    };
    oci-containers = {
      backend = "podman";
    };
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      networkSocket.openFirewall = true;
      extraPackages = [ pkgs.zfs ];
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
      # high memory pressure, you likeky are under high CPU load too
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
      };
    };
  };

  hardware.enableRedistributableFirmware = true;
}
