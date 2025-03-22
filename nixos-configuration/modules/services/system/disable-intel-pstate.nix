{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.disableIntelPstate;
in
lib.mkIf config.customOptions.socSupport.disableIntelPstate {
  systemd.services."${serviceConfig.unitName}" = {
      enable = true;
      before = serviceConfig.beforeUnits;
      wantedBy = serviceConfig.wantedByUnits;
      path = with pkgs; [
        coreutils-full
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = "echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo";
  };
}
