{ lib, ... }:

{
  options = {
    custom-options = {
      enableLocalStaticIpCheck = lib.mkOption {
        description = "Enable a check to ensure that the local static IP address assigned is the one that was requested.";
        type = lib.types.bool;
        default = true;
      };
      enableRootlessContainers = lib.mkOption {
        description = "Enable all systemd services that start rootless (Podman) containers for the home-manager user";
        type = lib.types.bool;
        default = false;
      };
    };
  };
}
