{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

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
      iputils
      nix
      openssh
      openssl
    ];
  };
in
lib.mkIf (!nixosSystemConfig.coreConfig.isNixOS) {
  systemd.user = {
    timers."${serviceConfig.unitName}" = {
      Install = {
        RequiredBy = [ "timers.target" ];
      };
      Timer = {
        Unit = "${serviceConfig.unitName}.service";
        OnCalendar = serviceConfig.onCalendar;
        OnBootSec = "10m";
      };
    };

    services."${serviceConfig.unitName}" = {
      Install = {
        WantedBy = [ "default.target" ];
      };
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

          if [[ ! -d ${localNixosConfigDir} ]]; then
              git clone https://gitlab.com/thefossguy/prathams-nixos.git ${localNixosConfigDir}
          fi

          pushd ${localNixosConfigDir} || exit 1
          git pull
          nix flake update
          nix build ${nixosSystemConfig.extraConfig.nixBuildArgs} .#homeConfigurations.${pkgs.stdenv.system}.${nixosSystemConfig.coreConfig.systemUser.username}.activationPackage
          ./result/activate || echo 'home-manager activation failed but exiting cleanly'
          popd || exit 0
        ''}";
      };
    };
  };
}
