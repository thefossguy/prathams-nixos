{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.continuousBuild;
in
lib.mkIf config.customOptions.localCaching.buildsNixDerivations {
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
        bash
        git
        nix
        nix-output-monitor
        python3
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        pushd /etc/nixos || exit 1
        rm -vf ./result*
        if ! ./scripts/nix-ci/wrapped-builder.sh; then
            git checkout master
            exit 1
        fi
        popd || exit 0
      '';
    };
  };
}
