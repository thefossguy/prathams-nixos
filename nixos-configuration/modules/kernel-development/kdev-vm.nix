{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf config.customOptions.kernelDevelopment.virt.enable {
  systemd.services."serial-getty@ttyS0".enable = true;
}
