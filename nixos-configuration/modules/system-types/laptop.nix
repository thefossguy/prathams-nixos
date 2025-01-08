{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.systemType == "laptop") {
  boot.kernelParams = [
    "hibernate=protect_image"
    "mem_sleep_default=deep"
    "pm_debug_messages"
  ];

  systemd.sleep.extraConfig = ''
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspend=yes
    AllowSuspendThenHibernate=yes
  '';
}
