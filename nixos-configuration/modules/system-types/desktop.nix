{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.systemType == "desktop") {
  boot.kernelParams = [
    "hibernate=protect_image"
    "mem_sleep_default=deep"
    "pm_debug_messages"
  ];
}
