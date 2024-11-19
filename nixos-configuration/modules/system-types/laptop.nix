{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.systemType == "laptop") {
  systemd.sleep.extraConfig = ''
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspend=yes
    AllowSuspendThenHibernate=yes
  '';
}
