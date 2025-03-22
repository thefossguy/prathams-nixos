{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.systemType == "laptop") {
  boot.kernelParams = [
    "hibernate=protect_image"
    "pm_debug_messages"
  ];

  programs.coolercontrol = {
    enable = true;
    nvidiaSupport = (builtins.elem "nvidia" config.customOptions.gpuSupport);
  };

  systemd.sleep.extraConfig = ''
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspend=yes
    AllowSuspendThenHibernate=yes
  '';
}
