{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  # Import only the system services. User services will be manually sourced by
  # the home-manager configurations.
  imports = [
    ./podman-container-services
    ./system
  ];
}
