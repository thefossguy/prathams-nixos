{
  config,
  lib,
  pkgs,
  osConfig ? { },
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  localCacheRemote = "chaturvyas";
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.syncNixBuildResults;
  appendedPath = import ../../../../functions/append-to-path.nix {
    packages = with pkgs; [
      coreutils
      findutils
      git
      nix
      openssh
      openssl
    ];
  };
in
lib.attrsets.optionalAttrs (osConfig.customOptions.localCaching.buildsNixDerivations or false) {
  systemd.user = {
    timers."${serviceConfig.unitName}" = {
      Install = {
        RequiredBy = [ "timers.target" ];
      };
      Timer = {
        Unit = "${serviceConfig.unitName}.service";
        OnCalendar = serviceConfig.onCalendar;
      };
    };

    services."${serviceConfig.unitName}" = {
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        Type = "oneshot";
        Environment = [ appendedPath ];

        ExecStart = "${pkgs.writeShellScript "${serviceConfig.unitName}-execstart.sh" ''
          set -xeuf -o pipefail

          if ! ssh -t ${localCacheRemote} 'cat /proc/sys/kernel/hostname' 1>/dev/null 2>&1; then
              echo 'SSH key not present on remote (${localCacheRemote}).'
              exit 1
          fi

          while [[ -f '/etc/nixos/flake-ci-started.log' ]]; do
              sleep 10
          done

          nixbuildResults=( $(find /etc/nixos -type l | tr '\r\n' ' ') )
          for targetFile in "''${nixbuildResults[@]}"; do
              nix copy --no-check-sigs --to ssh-ng://${localCacheRemote} "''${targetFile}"
          done
        ''}";
      };
    };
  };
}
