{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.getRedhatCsafVex;
  appendedPath = import ../../../../functions/append-to-path.nix {
    packages = with pkgs; [
      coreutils-full
      gnutar
      iputils
      wget
      zstd
    ];
  };
  vexDir = "${config.home.homeDirectory}/redhat";
  connectivityCheckScript = import ../../misc-imports/check-network.nix {
    internetEndpoint = "security.access.redhat.com";
    exitCode = "1";
    inherit pkgs;
  };
in
lib.mkIf pkgs.stdenv.isLinux {
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
      Service = {
        Type = "oneshot";
        Environment = [ appendedPath ];

        ExecStart = "${pkgs.writeShellScript "${serviceConfig.unitName}-ExecStart.sh" ''
          set -xeuf -o pipefail

          TZ='UTC'
          export TZ

          URL_WITHOUT_FILENAME='https://security.access.redhat.com/data/csaf/v2/vex'
          VEX_ARCHIVE_FILENAME="csaf_vex_$(date '+%Y-%m-%d').tar.zst"

          # Doesn't need to run on any of my personal machines
          # so exit only if the host machine is none of my personal machine.
          if [[ ! -d ${vexDir} ]]; then
              exit 0
          fi

          ${connectivityCheckScript}

          pushd ${vexDir} || exit 1
          if [[ ! -f "''${VEX_ARCHIVE_FILENAME}" ]]; then
              wget "''${URL_WITHOUT_FILENAME}/''${VEX_ARCHIVE_FILENAME}"
              tar --overwrite -xf "''${VEX_ARCHIVE_FILENAME}"
              rm -vf csaf_vex_*.tar.zst
          fi
          popd || exit 1
        ''}";
      };
    };
  };
}
