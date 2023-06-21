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
    ./services-built-in.nix

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
      dates = "weekly";
      allowReboot = true;
      operation = "boot";
      rebootWindow = {
        lower = "12:00";
        upper = "14:00";
      };
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
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

  documentation.man.enable = true;

  security = {
    #virtualisation.flushL1DataCache = true;
  };

  console = {
    enable = true;
    earlySetup = true;
  };

  programs.dconf.enable = true;

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
    kernelParams = [ "ignore_loglevel" "audit=0" ];
    kernel.sysctl = {
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
