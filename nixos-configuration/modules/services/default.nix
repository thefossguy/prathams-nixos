{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  # Import only the system services. User services will be manually sourced by
  # the home-manager configurations.
  imports = [ ./system ];
}
