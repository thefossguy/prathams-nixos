{ lib, ... }:

{
  options = {
    custom-options = {
      isNixosDesktop = lib.mkOption {
        description = "Enable desktop-specific NixOS options.";
        type = lib.types.bool;
        default = false;
      };
      isNixosLaptop = lib.mkOption {
        description = "Enable laptop-specific NixOS options.";
        type = lib.types.bool;
        default = false;
      };
      isNixosServer = lib.mkOption {
        description = "Enable server-specific NixOS options.";
        type = lib.types.bool;
        default = false;
      };

      runsVirtualMachines = lib.mkOption {
        description = "Machine that runs VM and so has other related things enabled.";
        type = lib.types.bool;
        default = false;
      };

      isNixOS = lib.mkOption {
        description = "An option for home-manager to check if it's on NixOS or not.";
        type = lib.types.bool;
        default = true;
      };

      isNixCacheMachine = lib.mkOption {
        description = "This machine serves Nix Cache.";
        type = lib.types.bool;
        default = false;
      };

      enableWebRemoteServices = lib.mkOption {
        description = "Enable all systemd services that start rootless (Podman) containers for the home-manager user";
        type = lib.types.bool;
        default = false;
      };
    };
  };
}
