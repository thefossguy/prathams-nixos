{ config, lib, pkgs, flakeUri, ... }:

{
  # we disable the systemd service that NixOS ships because we have our own "special sauce"
  system.autoUpgrade.enable = lib.mkForce false;

  systemd = {
    timers."custom-nixos-upgrade" = {
      enable = true;
      requiredBy = [ "timers.target" ];

      timerConfig = {
        Unit = "custom-nixos-upgrade";

        OnBootSec = "10m";
        OnCalendar = "hourly";
      };
    };

    services."custom-nixos-upgrade" = {
      enable = true;
      path = with pkgs; [
        diffutils
        gitMinimal
        nix
        nixos-rebuild
      ];

      requires = [ "network-online.target" ];

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
        nix flake update
        if ! diff flake.lock.old flake.lock > /dev/null; then
            lock_updated=1
        else
            lock_updated=0
        fi

        # Aham Brahmaasmi?
        if [[ "$(( conf_changed + lock_updated ))" -gt 0 ]]; then
            nixos-rebuild boot --show-trace --verbose --flake ${flakeUri}#${config.networking.hostName}
        else
            set +x
            echo 'DEBUG: no upgrade performed'
            echo "DEBUG: conf_changed: ''${conf_changed}"
            echo "DEBUG: lock_updated: ''${lock_updated}"
        fi
        popd
      '';
    };
  };
}
