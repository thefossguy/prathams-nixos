{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.overwriteBucketStoreInfo;
in
lib.mkIf config.customOptions.localCaching.servesNixDerivations {
  systemd = {
    timers."${serviceConfig.unitName}" = {
      enable = true;
      requiredBy = [ "timers.target" ];
      timerConfig.OnCalendar = serviceConfig.onCalendar;
      timerConfig.Unit = "${serviceConfig.unitName}.service";
    };

    services."${serviceConfig.unitName}" = {
      enable = true;
      path = with pkgs; [
        awscli2
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        echo -e 'StoreDir: /nix/store\nWantMassQuery: 1\nPriority: 10' | aws s3 cp - s3://thefossguy-nix-cache-001-8c0d989b-44cf-4977-9446-1bf1602f0088/nix-cache-info
      '';
    };
  };
}
