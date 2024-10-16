{ lib, pkgs, ... }:

let
  connectivityCheckScript = import ../misc-imports/check-network.nix {
    internetEndpoint = "security.access.redhat.com";
    exitCode = "1";
    inherit pkgs;
  };

in lib.mkIf pkgs.stdenv.isLinux {
  systemd.user.services = {
    "get-redhat-csaf-vex" = {
      Service = {
        ExecStart = "${pkgs.writeShellScript "get-redhat-csaf-vex-execstart.sh" ''
          set -xeuf -o pipefail

          PATH="$PATH:${pkgs.gnutar}/bin"
          HOME="''${HOME:-"/home/''${LOGNAME}"}"
          TZ='UTC'

          VEX_DIR="''${HOME}/redhat"

          export PATH
          export HOME
          export TZ

          url_without_filename='https://security.access.redhat.com/data/csaf/v2/vex'
          filename="csaf_vex_$(date '+%Y-%m-%d').tar.zst"

          # doesn't need to run on any of my personal machines
          # so exit early if we are on my work machine
          if [[ ! -d "''${VEX_DIR}" ]]; then
              exit 0
          fi

          ${connectivityCheckScript}
          pushd "''${VEX_DIR}"
          if [[ ! -f "''${filename}" ]]; then
              wget "''${url_without_filename}/''${filename}"
              tar -xf --overwrite "''${filename}"
              rm -vf csaf_vex_*.tar.zst
          fi
          popd
        ''}";
        Type = "oneshot";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };
  };

  systemd.user.timers = {
    "get-redhat-csaf-vex" = {
      Timer = {
        OnBootSec = "now";
        OnCalendar = "01:00 UTC";
        Unit = "get-redhat-csaf-vex.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}
