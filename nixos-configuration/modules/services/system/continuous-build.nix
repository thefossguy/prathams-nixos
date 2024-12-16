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
      path = with pkgs; [ git nix nix-output-monitor python3 ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = "python3 /etc/nixos/scripts/nix-ci/builder.py --nixosConfigurations --homeConfigurations --devShells --packages";
    };
  };
}
