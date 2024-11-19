{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.continuousBuild;
in lib.mkIf config.customOptions.localCaching.buildsNixDerivations {
  systemd = {
    timers."${serviceConfig.unitName}" = {
      enable = true;
      requiredBy = [ "timers.target" ];
      timerConfig.OnCalendar = serviceConfig.onCalendar;
      timerConfig.Unit = serviceConfig.unitName;
    };

    services."${serviceConfig.unitName}" = {
      enable = true;
      after = serviceConfig.afterUnits;
      requires = serviceConfig.requiredUnits;
      path = with pkgs; [ git nix ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xeuf -o pipefail

        pushd /etc/nixos || exit 1
        export USE_NIX_INSTEAD_OF_NOM=1
        time nix run .#continuousBuild
        popd || exit 1
      '';
    };
  };
}
