{ lib, pkgs, systemUser, ... }:

let
  homeDir = "/home/${systemUser.username}";
  hm_config_dir = "${homeDir}/.prathams-nixos";

in lib.mkIf pkgs.stdenv.isLinux {
  systemd.user.services = {
    "upgrade-my-home" = {
      Service = {
        ExecStart = "${pkgs.writeShellScript "upgrade-my-home-execstart.sh" ''
          set -xeuf -o pipefail

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
    "upgrade-my-home" = {
      Timer = {
        OnBootSec = "now";
        OnCalendar = "Monday *-*-* 07:00:00";
        Unit = "upgrade-my-home.service";
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}
