{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.systemType == "server") {
  boot.kernelParams = [ "cpufreq.default_governor=performance" ];
  systemd.sleep.extraConfig = ''
    AllowHibernation=no
    AllowSuspend=no
  '';
}
