{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.verifyNixStorePaths;
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
      after = serviceConfig.afterUnits;
      requires = serviceConfig.requiredUnits;
      path = with pkgs; [
        nix
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xeuf -o pipefail

        nixbuildResults=( $(find /etc/nixos -type l | tr '\r\n' ' ') )
        for targetFile in "''${nixbuildResults[@]}"; do
            nix store verify --recursive --sigs-needed 1 "/etc/nixos/''${targetFile}"
        done
      '';
    };
  };
}
