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

        [[ ! -d ${flakeUri} ]] && git clone https://gitlab.com/thefossguy/prathams-nixos ${flakeUri}
        pushd ${flakeUri}

        prev_hash=$(git rev-parse --verify HEAD)
        git pull
        if [[ "''${prev_hash}" != "$(git rev-parse --verify HEAD)" ]]; then
            conf_changed=1
        else
            conf_changed=0
        fi

        cp flake.lock flake.lock.old
        git restore flake.lock
        nix flake update
        if ! diff flake.lock.old flake.lock > /dev/null; then
            lock_updated=1
        else
            lock_updated=0
        fi

        # Aham Brahmaasmi?
        if [[ "$(( conf_changed + lock_updated ))" -gt 0 ]]; then
            ${pkgs.bash}/bin/bash ./scripts/nix-ci/nix-build-wrapper.sh machine ${config.networking.hostName}
        else
            echo 'DEBUG: no upgrade performed'
            echo "DEBUG: conf_changed: ''${conf_changed}"
            echo "DEBUG: lock_updated: ''${lock_updated}"
        fi
        popd
      '';
    };
  };
}
