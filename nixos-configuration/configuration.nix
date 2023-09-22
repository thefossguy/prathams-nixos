{ lib, pkgs, ... }:

{
  imports = [
    # generated by 'nixos-generate-config'
    ./hardware-configuration.nix

    # system packages (for all users)
    ./packages-system.nix

    # users, password-less-sudo and groups config
    ./users-configuration.nix

    # services to enable
    ./root-services.nix

    # zfs
    ./zfs-configuration.nix

    # specific to this host
    ./host-specific-configuration.nix

    # user services
    ./user-services/services-master.nix
  ];

  nixpkgs.config.allowUnfree = true; # allow non-FOSS pkgs
  system = {
    stateVersion = "23.05"; # release version of NixOS

    autoUpgrade = {
      enable = true;
      dates = "Sat *-*-* 00:00:00";
      allowReboot = true;
      operation = "boot";
      rebootWindow = {
        lower = "04:00";
        upper = "05:00";
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
    #virtualisation.flushL1DataCache = true;
  };

  console = {
    enable = true;
    earlySetup = true;
  };

  programs = {
    ccache.enable = true;
    dconf.enable = true;
    adb.enable = true;
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
      # TODO: define containers here
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

  # good for perf
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 75;
  };

  boot = {
    kernelParams = [
      "audit=0"
      "ignore_loglevel"

      "boot.shell_on_fail"

      "fsck.mode=auto"

      "plymouth.enable=0"
      "rd.plymouth=0"
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
      efi.canTouchEfiVariables = true;
      timeout = 5;
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
    };
  };

  hardware.enableRedistributableFirmware = true;
}
