{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  connectivityCheckScript = import ../../misc-imports/check-network.nix {
    internetEndpoint = "cache.nixos.org";
    inherit pkgs;
  };
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.updateNixosFlakeInputs;

  nixosConfigDir = "/etc/nixos";
  nixosConfigRemoteUrl = "https://gitlab.com/thefossguy/prathams-nixos.git";
in
{
  systemd.services."${serviceConfig.unitName}" = {
    enable = true;
    path = with pkgs; [
      gitMinimal
      iputils
      nix
    ];

    serviceConfig = {
      User = "root";
      Type = "oneshot";
    };

    script = ''
      set -xuf -o pipefail

      ${connectivityCheckScript}

      if ! git -C ${nixosConfigDir} status >/dev/null 2>&1; then
          # So far, this can fail for two reasons:
          # 1. The Git repository does not exist. In which case, nothing precious
          #    was inside it that I would be sad losing.
          # 2. Sometimes, the Git repository can get corrupted.
          rm -rf ${nixosConfigDir}
      fi

      if [[ ! -d ${nixosConfigDir} ]]; then
          git clone ${nixosConfigRemoteUrl} ${nixosConfigDir}
      fi

      pushd ${nixosConfigDir} || exit 1
      git pull --no-rebase

      SECONDS_SINCE_EPOCH="$(date +'%s')"
      LAST_MODIFIED_TIMESTAMP_IN_EPOCH_SECONDS="$(stat -c '%Y' flake.lock)"
      LAST_MODIFIED_TIMESTAMP_IN_MINUTES="$(( $(( SECONDS_SINCE_EPOCH - LAST_MODIFIED_TIMESTAMP_IN_EPOCH_SECONDS )) / 60 ))"
      if [[ "''${LAST_MODIFIED_TIMESTAMP_IN_MINUTES}" -gt 50 ]]; then
          nix flake update
      else
          echo "Not updating flake.lock to be under GitHub's free rate limit."
      fi

      popd || exit 1
    '';
  };
}
