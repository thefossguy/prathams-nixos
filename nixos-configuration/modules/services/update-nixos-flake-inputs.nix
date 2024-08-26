{ pkgs, ... }:

let
  connectivityCheckScript = import ../modules/misc-imports/check-network.nix {
    internetEndpoint = "cache.nixos.org";
    exitCode = "1";
    inherit pkgs;
  };
in {
  systemd = {
    services."update-nixos-flake-inputs" = {
      enable = true;
      path = with pkgs; [ gitMinimal nix ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xuf -o pipefail

        ${connectivityCheckScript}

        if [[ ! -d /etc/nixos/.git ]]; then
            # if /etc/nixos/.git doesn't exist, then
            # whatever is in there doesn't matter to me, or I would've included it in the git tree
            # so rm -rf it
            rm -rf /etc/nixos
            git clone https://gitlab.com/thefossguy/prathams-nixos /etc/nixos
        fi

        pushd /etc/nixos
        git pull --no-rebase

        if [[ "$(echo $(( $(( $(date +'%s') - $(stat -c '%Y' flake.lock) )) / 60 )))" -gt 50 ]]; then
            nix flake update
        else
            echo "Not updating flake.lock to be under GitHub's limit"
        fi
        popd
      '';
    };
  };
}
