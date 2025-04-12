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

        verificationCode=0
        isBuilder=${if (config.customOptions.localCaching.buildsNixDerivations or false) then "1" else "0"}

        nix store verify --all --recursive --sigs-needed 1 >/dev/null 2>&1 || verificationCode=$?

        if [[ "''${verificationCode}" -eq 2 ]]; then
            if [[ "''${isBuilder}" -eq 1 ]]; then
                # Exit cleanly only if the `nix store verify` command exits
                # with return code 2 on a builder.
                exit 0
            else
                # Exit with the original return code
                exit "''${verificationCode}"
            fi
        else
            # Exit with the original return code
            exit "''${verificationCode}"
        fi
      '';
    };
  };
}
