{ lib, pkgs, systemUser, ... }:

let
  homeDir = "/home/${systemUser.username}";
  hm_config_dir = "${homeDir}/.prathams-nixos";
  connectivityCheckScript = import ../includes/misc-imports/check-network.nix {
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

          ${connectivityCheckScript}

          [[ ! -d ${hm_config_dir} ]] && ${pkgs.gitMinimal}/bin/git clone https://gitlab.com/thefossguy/prathams-nixos ${hm_config_dir}

          pushd ${hm_config_dir}
          ${pkgs.gitMinimal}/bin/git pull
          ${pkgs.nix}/bin/nix flake update
          ${pkgs.home-manager}/bin/home-manager -v --show-trace --print-build-logs --flake . switch
          ${pkgs.home-manager}/bin/home-manager expire-generations '-1 days'
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
