{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.copyNixStorePathsToLinode;
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
            realPath="$(realpath "''${targetFile}")"
            nix copy --to s3://thefossguy-public-nix-binary-cache?endpoint=us-lax-1.linodeobjects.com "''${realPath}"
        done
      '';
    };
  };
}
