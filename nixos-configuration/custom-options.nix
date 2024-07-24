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

      enableWebRemoteServices = lib.mkOption {
        description = "Enable all systemd services that start rootless (Podman) containers for the home-manager user";
        type = lib.types.bool;
        default = false;
      };
    };
  };
}
