{ config, pkgs, ... }:

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
    dconf.enable = true;
    adb.enable = true;
  };

  environment = {
    homeBinInPath = true;
    localBinInPath = true;
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SYSTEMD_EDITOR = "nvim";
      TERM = "xterm-256color";
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
    kernelParams = [ "ignore_loglevel" "audit=0" "boot.shell_on_fail" ];
    kernel.sysctl = {
      # Using zramswap, penalty shouldn't be that high, since if you are under
      # high memory pressure, you likeky are under high CPU load too
      # at which point, you are performing computations and latency goes moot
      "vm.swappiness" = 180;

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
