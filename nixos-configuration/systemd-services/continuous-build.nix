{ pkgs, ... }:

let
  connectivityCheckScript = import ../includes/misc-imports/check-network.nix {
    internetEndpoint = "cache.nixos.org";
    exitCode = "1";
    inherit pkgs;
  };
in

{
  nix.settings.max-jobs = 1;
  systemd = {
    services."continuous-build" = {
      enable = true;
      before = [ "custom-nixos-upgrade.service" ];
      wantedBy = [ "custom-nixos-upgrade.service" ];
      path = with pkgs; [
        gitMinimal
        nix
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xuf -o pipefail

        ${connectivityCheckScript}

        [[ ! -d /etc/nixos/.git ]] && git clone https://gitlab.com/thefossguy/prathams-nixos /etc/nixos
        pushd /etc/nixos
        git pull
        nix flake update
        time nix run .#continuousBuild
        popd
      '';
    };
  };
}
