{ config
, lib
, pkgs
, systemUser
, flakeUri
, ...
}:

{
  systemd = {
    timers."lookahead-nixos-build" = {
      enable = true;
      requiredBy = [ "timers.target" ];

      timerConfig = {
        Unit = "lookahead-nixos-build";

        OnBootSec = "10m";
        OnCalendar = "hourly";
      };
    };

    services."lookahead-nixos-build" = {
      enable = true;
      path = with pkgs; [
        gitMinimal
        nix
      ];

      requires = [ "network-online.target" ];
      before = [ "nixos-upgrade.service" ];
      requiredBy = [ "nixos-upgrade.service" ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xuf -o pipefail

        # we do not _need to_ build hourly on machines with more than 4 GiB of RAM
        CURRENT_TIME_IN_INDIA="$(TZ='Asia/Kolkata' date +%H:%M)"
        TOTAL_MEM_IN_KIB="$(grep 'MemTotal' /proc/meminfo | awk '{print $2}')"
        TOTAL_MEM_IN_GIB="$(( TOTAL_MEM_IN_KIB / 1024 / 1024 ))"
        if [[ "$TOTAL_MEM_IN_GIB" -gt 4 ]] && [[ "$CURRENT_TIME_IN_INDIA" != '00:00' ]]; then
            echo 'System has more than 4 GiB of RAM. Will run only at 00:00 IST. Skipping for now.'
            exit 0
        fi

        [[ ! -d ${flakeUri} ]] && git clone https://gitlab.com/thefossguy/prathams-nixos ${flakeUri}

        pushd ${flakeUri}
        git restore flake.lock
        git pull
        nix flake update
        nix build --print-build-logs --show-trace .#machines.${config.networking.hostName}
        popd
      '';
    };
  };
}
