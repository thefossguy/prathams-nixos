{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.verifyNixStorePaths;
in
lib.mkIf (!config.customOptions.localCaching.servesNixDerivations) {
  systemd = {
    timers."${serviceConfig.unitName}" = {
      enable = true;
      requiredBy = [ "timers.target" ];
      timerConfig.OnCalendar = serviceConfig.onCalendar;
      timerConfig.Unit = "${serviceConfig.unitName}.service";
    };

    services."${serviceConfig.unitName}" = {
      enable = true;
      before = serviceConfig.beforeUnits;
      requiredBy = serviceConfig.requiredByUnits;

      path = [ pkgs.nix ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -x
        set +e

        nix store verify --all --recursive >/dev/null 2>&1
        returnCode=$?
        if [[ "''${returnCode}" -ne 0 ]] || [[ "''${returnCode}" -ne 2 ]] || [[ "''${returnCode}" -ne 4 ]]; then
            # 0 is successful
            # 2 is untrusted (no signatures, probably built locally)
            # 4 encountered I/O error
            exit 0
        else
            echo 'Some nix store paths are corrupted, attempting to verify'
            set -e
            nix store repair --all --recursive
        fi
      '';
    };
  };
}
