{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.customHomeManagerUpgrade;
  localNixosConfigDir = "${config.home.homeDirectory}/.prathams-nixos";
  connectivityCheckScript = import ../../misc-imports/check-network.nix {
    internetEndpoint = "cache.nixos.org";
    inherit pkgs;
  };
  appendedPath = import ../../../../functions/append-to-path.nix {
    packages = with pkgs; [
      git
      home-manager
      nix
      openssh
      openssl
    ];
  };
in lib.mkIf pkgs.stdenv.isLinux {
  systemd.user = {
    timers."${serviceConfig.unitName}" = {
      Install = { RequiredBy = [ "timers.target" ]; };
      Timer = {
        Unit = "${serviceConfig.unitName}.service";
        OnCalendar = serviceConfig.onCalendar;
      };
    };

    services."${serviceConfig.unitName}" = {
      Install = { WantedBy = [ "default.target" ]; };
      Unit = {
        After = serviceConfig.afterUnits;
        Requires = serviceConfig.requiredUnits;
      };
      Service = {
        Type = "oneshot";
        Environment = [ appendedPath ];

        ExecStart = "${pkgs.writeShellScript "${serviceConfig.unitName}-execstart.sh" ''
          set -xeuf -o pipefail

          ${connectivityCheckScript}

          pushd ${localNixosConfigDir} || exit 1
          git pull
          nix flake update
          nix build ${nixosSystemConfig.extraConfig.nixBuildArgs} .#homeConfigurations.${pkgs.stdenv.system}.${nixosSystemConfig.coreConfig.systemUser.username}.activationPackage
          ./result/activate
          popd || exit 1
        ''}";
      };
    };
  };
}
