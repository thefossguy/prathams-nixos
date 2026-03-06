{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.systemType == "laptop") {
  services.thermald.enable = (config.customOptions.x86CpuVendor == "intel");
  boot.kernelParams = [
    "hibernate=protect_image"
    "pm_debug_messages"
  ];

  systemd.sleep.settings.Sleep = {
    AllowHibernation = "yes";
    AllowHybridSleep = "yes";
    AllowSuspend = "yes";
    AllowSuspendThenHibernate = "yes";
  };
}
