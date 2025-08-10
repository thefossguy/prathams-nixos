{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:
# TODO: Remove this let-in block after RISC-V support is added to nixpkgs
let
  localStdenv = pkgs.stdenv // {
    isRiscV64 = pkgs.stdenv.hostPlatform.isRiscV;
  };
  kernelPackagesSet = {
    mainline = pkgs.linux_testing;
    stable = pkgs.linux_latest;
    longterm = pkgs.linux_6_12;
  };
in

{
  options.customOptions = {
    userHomeDir = lib.mkOption {
      description = "An internal option to track the $HOME dir for non-root user.";
      type = lib.types.str;
      default = config.users.users.${nixosSystemConfig.coreConfig.systemUser.username}.home;
    };

    finalBuildTarget = lib.mkOption {
      description = "A shorthand build target that builds the final target for NixOS system and the ISO.";
      type = lib.types.package;
      default = if (!config.customOptions.isIso) then config.system.build.toplevel else config.system.build.isoImage;
    };

    systemType = lib.mkOption {
      description = "Enable configuration that is specific to a Server/Desktop/Laptop.";
      type = lib.types.enum [
        "server"
        "desktop"
        "laptop"
      ];
      default = "server";
    };

    dhcpConfig = lib.mkOption {
      description = "DHCP configuration.";
      type = lib.types.enum [
        "ipv4"
        "ipv6"
        "no"
        "yes"
      ];
      default = if nixosSystemConfig.extraConfig.useDHCP then "yes" else "no";
    };

    useMinimalConfig = lib.mkOption {
      description = "Install and configure as little stuff as possible. Defaults to `true`.";
      type = lib.types.bool;
      default = config.customOptions.systemType == "server";
    };

    useAlternativeSSHPort = lib.mkOption {
      description = "Whether to use a different port (6922) instead for SSH.";
      type = lib.types.bool;
      default = false;
    };

    isIso = lib.mkOption {
      description = "An internal check to toggle options based on if a given NixOS system is an ISO.";
      type = lib.types.bool;
      default = ((config.image.fileName or "") != "");
    };

    enableWlanPersistentNames = lib.mkOption {
      description = "Weather to enable persistent naming for wlan interfaces. Enable only when said iface has a `permaddr`.";
      type = lib.types.bool;
      default = false;
    };

    socSupport = {
      enabled = lib.mkOption {
        description = "An internal-only option.";
        default = (
          (config.customOptions.socSupport.armSoc != "unset") || (config.customOptions.socSupport.riscvSoc != "unset")
        );
        type = lib.types.bool;
      };
      handleFirmwareUpdates = lib.mkOption {
        description = "If a given SoC requires NixOS to handle the firmware updates.";
        # TODO: Enable RISC-V support once nixpkgs has it too.
        default = ((config.customOptions.socSupport.armSoc != "unset") && (config.customOptions.socSupport.armSoc != "m4"));
        type = lib.types.bool;
      };
      disableIntelPstate = lib.mkOption {
        description = "Disable Intel pstate on some thermally sensitive systems.";
        default = (config.customOptions.socSupport.x86Soc == "n100");
        type = lib.types.bool;
      };
      x86Soc = lib.mkOption {
        description = "Enable support for some x86_64 SoCs.";
        default = "unset";
        type = lib.types.enum [
          "n100"

          "unset"
        ];
      };
      armSoc = lib.mkOption {
        description = "Enable support for some Aarch64 SoCs.";
        default = "unset";
        type = lib.types.enum [
          "rk3588"
          "rpi4"
          "rpi5"
          "m4"

          "unset"
        ];
      };
      riscvSoc = lib.mkOption {
        description = "Enable support for some RISC-V SoCs.";
        default = "unset";
        type = lib.types.enum [
          "eic7700"
          "jh7110"
          "sg2380"

          "unset"
        ];
      };
    };

    virtualisation = {
      enable = lib.mkOption {
        description = "Enable my NixOS configurations that I find useful for virtualisation.";
        type = lib.types.bool;
        default = false;
      };
      enableVirtualBridge = lib.mkOption {
        description = ''
          Enable the virtual bridge. Enabled automatically when
          `config.customOptions.virtualisation.enable` is enabled.
        '';
        type = lib.types.bool;
        default = config.customOptions.virtualisation.enable;
      };
    };

    localCaching = {
      servesNixDerivations = lib.mkOption {
        description = "This machine serves a binary cache for Nix derivations.";
        type = lib.types.bool;
        default = false;
      };

      buildsNixDerivations = lib.mkOption {
        description = "This machine builds Nix derivations.";
        type = lib.types.bool;
        default = false;
      };
    };

    podmanContainers = {
      containersDirPath = lib.mkOption {
        description = "The basedir for all podman containers' volumes.";
        type = lib.types.str;
        default = "/home/${nixosSystemConfig.coreConfig.systemUser.username}/containers/volumes";
      };
      enableHomelabServices = lib.mkOption {
        description = ''
          Enable Podman containers (as rootless systemd services) for
          `${nixosSystemConfig.coreConfig.systemUser}`. These services
          typically include self-hosted software like Nextcloud, Gitea, etc.
        '';
        type = lib.types.bool;
        default = config.customOptions.podmanContainers.homelabServices != [ ];
      };
      homelabServices = lib.mkOption {
        description = "Rootless podman services to enable.";
        default = [ ];
        type = lib.types.listOf (
          lib.types.enum [
            "transmission0x0"
          ]
        );
      };
    };

    wireguardOptions = {
      wgPrivateKeyDir = lib.mkOption {
        description = "A global option to ensure consistency of the wireguard connection's private key file's path.";
        default = "/etc/nixos/nixos-configuration/modules/wg-vpn";
        type = lib.types.str;
      };
      routes = lib.mkOption {
        description = "A list of all `networking.dhcpcd.runHook`s for routing wireguard traffic.";
        default = [ ];
        type = lib.types.listOf lib.types.str;
      };
      enabledVPNs = lib.mkOption {
        description = "A list of all enabled wireguard VPNs.";
        default = [ ];
        type = lib.types.listOf (
          lib.types.enum [
            "wg0x0"
            "wg0x1"
            "wg0x2"
          ]
        );
      };
    };

    x86CpuVendor = lib.mkOption {
      description = "List of GPU vendors to enable support for.";
      default = null;
      type = lib.types.enum [
        "amd"
        "intel"

        null
      ];
    };

    gpuSupport = lib.mkOption {
      description = "List of GPU vendors to enable support for.";
      default = [ ];
      type = lib.types.listOf (
        lib.types.enum [
          "amd"
          "intel"
          "nvidia"
        ]
      );
    };

    displayServer = {
      guiSession = lib.mkOption {
        description = "The GUI session to use.";
        default = if (config.customOptions.systemType == "server") then "unset" else "cosmic";
        type = lib.types.enum [
          "bspwm"
          "cosmic"
          "hyprland"
          "kde"

          "unset"
        ];
      };

      waylandEnabled = lib.mkOption {
        description = ''
          Set this to `true` when the DE/WM that you use uses Wayland for
          other dependencies to properly pick up wayland support. For example,
          so that browsers work well on NixOS (exporting NIXOS_OZONE_WL
          correctly).
        '';
        default = (
          config.customOptions.displayServer.guiSession != "unset" && config.customOptions.displayServer.guiSession != "bspwm"
        );
        type = lib.types.bool;
      };
    };

    autologinSettings = {
      getty.enableAutologin = lib.mkOption {
        description = "Enable getty autologin for `${nixosSystemConfig.coreConfig.systemUser.username}`.";
        type = lib.types.bool;
        default = config.customOptions.autologinSettings.guiSession.enableAutologin;
      };

      guiSession.enableAutologin = lib.mkOption {
        description = "Enable display server autologin for `${nixosSystemConfig.coreConfig.systemUser.username}`.";
        type = lib.types.bool;
        default = false;
      };
    };

    enablePasswordlessSudo = lib.mkOption {
      description = "Enable password-less `sudo`.";
      type = lib.types.bool;
      default = false;
    };

    enableQemuBinfmt = lib.mkOption {
      description = "Enable QEMU's foreign ISA emulation using binfmt.";
      type = lib.types.bool;
      default = config.customOptions.localCaching.servesNixDerivations;
    };

    kernelConfiguration = {
      tree = lib.mkOption {
        description = "The kernel tree to use.";
        type = lib.types.enum [
          "stable"
          "longterm"
          "mainline"
        ];
        default = nixosSystemConfig.kernelConfig.tree;
      };
      colonelPackages = lib.mkOption {
        description = "The base kernel package to use from nixpkgs.";
        type = lib.types.package;
        default = kernelPackagesSet."${config.customOptions.kernelConfiguration.tree}";
      };
    };

    kernelDevelopment = {
      enable = lib.mkOption {
        description = "Enable everything for Kernel development.";
        type = lib.types.bool;
        default = false;
      };

      virt.enable = lib.mkOption {
        description = "This option enables options for a VM used for testing development kernels.";
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config.assertions =
    [ ]

    ++ lib.optionals (config.customOptions.socSupport.x86Soc != "unset") [
      {
        assertion = pkgs.stdenv.isx86_64 && nixosSystemConfig.coreConfig.isNixOS;
        message = "The option `customOptions.socSupport.x86Soc` can only be set on NixOS on x86_64.";
      }
    ]

    ++ lib.optionals (config.customOptions.socSupport.armSoc != "unset") [
      {
        assertion = pkgs.stdenv.isAarch64 && nixosSystemConfig.coreConfig.isNixOS;
        message = "The option `customOptions.socSupport.armSoc` can only be set on NixOS on AArch64.";
      }
    ]

    ++
      lib.optionals
        (
          config.customOptions.socSupport.armSoc == "rk3588"
          || config.customOptions.socSupport.armSoc == "rpi4"
          || config.customOptions.socSupport.armSoc == "rpi5"
        )
        [
          {
            assertion = nixosSystemConfig.extraConfig.dtbRelativePath != null;
            message = "You need to provide a path relative to `dtbs/` for the device-tree binary for your board.";
          }
        ]

    ++ lib.optionals (config.customOptions.socSupport.riscvSoc != "unset") [
      {
        assertion = localStdenv.isRiscV64 && nixosSystemConfig.coreConfig.isNixOS;
        message = "The option `customOptions.socSupport.riscvSoc` can only be set on NixOS on 64-bit RISC-V.";
      }
    ];
}
