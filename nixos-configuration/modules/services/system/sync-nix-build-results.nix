{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  localCacheRemoteUser = "pratham";
  localCacheRemote = "chaturvyas";
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.syncNixBuildResults;
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
        coreutils-full
        findutils
        nix
        openssh
        openssl
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xeuf -o pipefail
        nix store ping --store 'ssh-ng://${localCacheRemoteUser}@${localCacheRemote}?ssh-key=/home/pratham/.ssh/ssh'
        nix copy --no-check-sigs --to 'ssh-ng://${localCacheRemoteUser}@${localCacheRemote}?ssh-key=/home/pratham/.ssh/ssh' $(find /etc/nixos -type l | tr '\r\n' ' ' | xargs realpath)
      '';
    };
  };
}
