{ lib, pkgs, systemUser, ... }:

let
  homeDir = "/home/${systemUser.username}";
  hm_config_dir = "${homeDir}/.prathams-nixos";
  connectivityCheckScript = import ../modules/misc-imports/check-network.nix {
    internetEndpoint = "cache.nixos.org";
    exitCode = "0";
    inherit pkgs;
  };

in lib.mkIf pkgs.stdenv.isLinux {
  services.home-manager.autoUpgrade.enable = lib.mkForce false;

  systemd.user.services = {
    "custom-home-manager-upgrade" = {
      Service = {
        ExecStart = "${pkgs.writeShellScript "custom-home-manager-upgrade-execstart.sh" ''
          set -xeuf -o pipefail
          PATH="$PATH:${pkgs.gitMinimal}/bin:${pkgs.nix}/bin:${pkgs.home-manager}/bin"
          export PATH

          ${connectivityCheckScript}

          [[ ! -d ${hm_config_dir} ]] && git clone https://gitlab.com/thefossguy/prathams-nixos ${hm_config_dir}

          pushd ${hm_config_dir}
          git pull
          nix flake update
          home-manager -v --show-trace --print-build-logs --flake . switch
          home-manager expire-generations '-1 days'
          popd
        ''}";
        Type = "oneshot";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };
  };

  systemd.user.timers = {
    "custom-home-manager-upgrade" = {
      Timer = {
        OnBootSec = "now";
        OnCalendar = "Monday *-*-* 07:00:00";
        Unit = "custom-home-manager-upgrade.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}
