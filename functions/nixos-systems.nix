{ linuxSystems, fullUserSet }:
let
  systemTypes = {
    server  = "server";
    desktop = "desktop";
    laptop  = "laptop";
  };
in {
  commonConfig = {
    gatewayAddr = "10.0.0.1";
    ipv4PrefixLength = 24;
    supportedFilesystemsSansZfs = {
      cifs = true;
      ext4 = true;
      overlay = true;
      squashfs = true;
      tmpfs = true;
      vfat = true;
      xfs = true;
      #zfs = ...; # Don't assign `zfs`, that is done in `nixos-configuration/modules/base-config/kernel-packages.nix`.
    };
    systemTypes = systemTypes;

    hostIds = {
      # generate the `hostId` using `head -c4 /dev/urandom | od -A none -t x4 | xargs`
      flameboi   = "20c95fe3";
      indra      = "d92f6246";
      madhav     = "102b6927";
      matsya     = "3852eff0";
      sentinel   = "041d6ae7";
      reddish    = "996ccb68";
      mahadev    = "c06c1a49";
      pawandev   = "2fefd3b2";
      stuti      = "07ca9dd4";
      chaturvyas = "6e52044b";
      raajan     = "337088b4";
      bhim       = "03c38aa0";
      bheem      = "6cca5083";
      vaaman     = "3c8077f9";
      vaayu      = "d81cd923";
    };
  };

  systems = {
    # "former" (now dead) "AI" "learning" PC (64GB; R9 3900XT; RTX 3070)
    flameboi = {
      coreConfig = {
        hostname = "flameboi";
        ipv4Address = "10.0.0.13";
        primaryNetIface = "eth0";
        system = linuxSystems.x86_64;
      };
      extraConfig = { systemType = systemTypes.desktop; };
    };

    # Lenovo Yoga Slim 6 (16GB; i5-13500H; Iris Xe)
    indra = {
      coreConfig = {
        hostname = "indra";
        ipv4Address = "10.0.0.50";
        primaryNetIface = "wlp0s20f3";
        system = linuxSystems.x86_64;
      };
      extraConfig = { systemType = systemTypes.laptop; };
    };

    # x86_64 NAS (16GB ECC; R5 3500X)
    madhav = {
      coreConfig = {
        hostname = "madhav";
        ipv4Address = "10.0.0.108";
        primaryNetIface = "enx9c6b002245ab";
        system = linuxSystems.x86_64;
      };
      kernelConfig.useLongtermKernel = true;
    };

    # Radxa X4 (12GB; N100)
    matsya = {
      coreConfig = {
        hostname = "matsya";
        ipv4Address = "10.0.0.109";
        primaryNetIface = "enx1002b586054e";
        system = linuxSystems.x86_64;
      };
    };

    # Raspberry Pi 4 Model B (4GB)
    sentinel = {
      coreConfig = {
        hostname = "sentinel";
        ipv4Address = "10.0.0.14";
        primaryNetIface = "enxdca6322f1a7c";
        system = linuxSystems.aarch64;
      };
    };

    # Raspberry Pi 4 Model B (8GB)
    reddish = {
      coreConfig = {
        hostname = "reddish";
        ipv4Address = "10.0.0.19";
        primaryNetIface = "enxe45f015fa482";
        system = linuxSystems.aarch64;
      };
    };

    # Raspberry Pi 5 Model B (8GB)
    raajan = {
      coreConfig = {
        hostname = "raajan";
        ipv4Address = "10.0.0.59";
        primaryNetIface = "end0";
        system = linuxSystems.aarch64;
      };
    };

    # Radxa ROCK 5 Model B (16GB; RK3588)
    mahadev = {
      coreConfig = {
        hostname = "mahadev";
        ipv4Address = "10.0.0.21";
        primaryNetIface = "enP4p65s0";
        system = linuxSystems.aarch64;
      };
    };

    # Xunlong Orange Pi 5 (4GB; RK3588S)
    pawandev = {
      coreConfig = {
        hostname = "pawandev";
        ipv4Address = "10.0.0.22";
        primaryNetIface = "enx326a3f36cd7e";
        system = linuxSystems.aarch64;
      };
    };

    # FriendlyElec NanoPC-T6 (16GB; RK3588)
    stuti = {
      coreConfig = {
        hostname = "stuti";
        ipv4Address = "10.0.0.23";
        primaryNetIface = "enP4p65s0"; # second one from the right
        system = linuxSystems.aarch64;
      };
    };

    # FriendlyElec CM3588 NAS (16GB; RK3588)
    chaturvyas = {
      coreConfig = {
        hostname = "chaturvyas";
        ipv4Address = "10.0.0.24";
        primaryNetIface = "enP4p65s0";
        system = linuxSystems.aarch64;
      };
      kernelConfig.useLongtermKernel = true;
    };

    # ARM64 VM (16G; 8x M4) guest on `bheem`
    bhim = {
      coreConfig = {
        hostname = "bhim";
        ipv4Address = "10.0.0.103";
        primaryNetIface = "enxcacf915df82c";
        system = linuxSystems.aarch64;
      };
    };

    # Apple Mac Mini host (32GB; M4)
    bheem = {
      coreConfig = {
        hostname = "bheem";
        ipv4Address = "10.0.0.35";
        primaryNetIface = "";
        system = linuxSystems.aarch64;
      };
    };

    # StarFive VisionFive 2 (8GB; JH7110)
    vaaman = {
      coreConfig = {
        hostname = "vaaman";
        ipv4Address = "10.0.0.41";
        primaryNetIface = "end0"; # first one from the right
        system = linuxSystems.riscv64;
      };
    };

    # StarFive VisionFive 2 (4GB; JH7110)
    vaayu = {
      coreConfig = {
        hostname = "vaayu";
        ipv4Address = "10.0.0.42";
        primaryNetIface = "end0"; # first one from the right
        system = linuxSystems.riscv64;
      };
    };
  };
}
