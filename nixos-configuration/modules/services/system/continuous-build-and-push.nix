{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.continuousBuildAndPush;
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
        python3 ./scripts/nix-ci/builder.py --nixosConfigurations --homeConfigurations --devShells --packages
        popd || exit 1

        nix store ping --store 'ssh-ng://pratham@10.0.0.24?ssh-key=/home/pratham/.ssh/ssh'
        nix copy --no-check-sigs --to 'ssh-ng://pratham@10.0.0.24?ssh-key=/home/pratham/.ssh/ssh' $(find /etc/nixos -type l | tr '\r\n' ' ' | xargs realpath)
      '';
    };
  };
}
