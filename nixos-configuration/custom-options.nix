{ lib, ... }:

{
  options = {
    custom-options = {
      enableWebRemoteServices = lib.mkOption {
        description = "Enable all systemd services that start rootless (Podman) containers for the home-manager user";
        type = lib.types.bool;
        default = false;
      };
    };
  };
}
