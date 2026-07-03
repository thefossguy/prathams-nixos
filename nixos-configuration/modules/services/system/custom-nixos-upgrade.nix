{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.customNixosUpgrade;
in
{
  # we disable the systemd service that NixOS ships because we have our own "special sauce"
  system.autoUpgrade.enable = lib.mkForce false;

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
      environment = {
        NIXOS_MACHINE_HOSTNAME = config.networking.hostName;
      };

      serviceConfig = {
        User = "root";
        Type = "oneshot";
        ExecStart = pkgs.writeScript "custom-nixos-upgrade.sh" ''
          #!${lib.getExe pkgs.bash}
          set -xeuf -o pipefail

          export PATH=${lib.makeBinPath (builtins.map (pkg: pkg.out or pkg) pkgs.custom-nixos-upgrade.buildInputs)}:$PATH
          if [[ -x /etc/nixos/scripts/nixos/custom-nixos-upgrade.py ]]; then
              exec ${lib.getExe pkgs.python3Minimal} /etc/nixos/scripts/nixos/custom-nixos-upgrade.py
          else
              exec ${lib.getExe pkgs.python3Minimal} ${lib.getExe pkgs.custom-nixos-upgrade}
          fi
        '';
      };
    };
  };
}
