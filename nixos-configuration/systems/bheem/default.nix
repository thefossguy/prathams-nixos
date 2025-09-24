{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  # Switches the Left Alt and CMD key as well as the Right Alt and CMD key.
  boot.kernelParams = [
    "hid_apple.swap_opt_cmd=1"
  ];

  customOptions.socSupport.armSoc = "m4";
}
