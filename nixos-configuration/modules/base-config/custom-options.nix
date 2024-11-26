{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  options.customOptions = {
    systemType = lib.mkOption {
      description = "Enable configuration that is specific to a Server/Desktop/Laptop.";
      type = lib.types.enum [ "server" "desktop" "laptop" ];
      default = "server";
    };

    useMinimalConfig = lib.mkOption {
      description = "Install and configure as little stuff as possible. Defaults to `true`.";
      type = lib.types.bool;
      default = config.customOptions.systemType == "server";
    };

    isIso = lib.mkOption {
      description = "An internal check to toggle options based on if a given NixOS system is an ISO.";
      type = lib.types.bool;
      default = ((config.isoImage.isoName or "") != "");
    };

    socSupport = {
      enabled = lib.mkOption {
        description = "An internal-only option.";
        default = ((config.customOptions.socSupport.armSoc != "unset") || (config.customOptions.socSupport.riscvSoc != "unset"));
        type = lib.types.bool;
      };
      armSoc = lib.mkOption {
        description = "Enable support for some Aarch64 SoCs.";
        default = "unset";
        type = lib.types.enum [
          "rk3588"
          "rpi4"
          "rpi5"

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
      enableHomelabServices = lib.mkOption {
        description = ''
          Enable Podman containers (as rootless systemd services) for
          `${nixosSystemConfig.coreConfig.systemUser}`. These services
          typically include self-hosted software like Nextcloud, Gitea, etc.
        '';
        type = lib.types.bool;
        default = false;
      };
    };

    cpuMicrocodeVendor = lib.mkOption {
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
      type = lib.types.listOf (lib.types.enum [ "amd" "intel" "nvidia" ]);
    };

    displayServer = {
      guiSession = lib.mkOption {
        description = "The GUI session to use.";
        default = if (config.customOptions.systemType == "server") then "unset" else "cosmic";
        type = lib.types.enum [
          "bspwm"
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
        default = (config.customOptions.displayServer.guiSession != "unset"
          && config.customOptions.displayServer.guiSession != "bspwm");
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
      default = false;
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
}
