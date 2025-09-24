{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf config.customOptions.kernelDevelopment.virt.enable {
  systemd.services."serial-getty@ttyS0".enable = true;
}
