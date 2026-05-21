{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.customNixosUpgrade;
in
{
  # we disable the systemd service that NixOS ships because we have our own "special sauce"
  system.autoUpgrade.enable = lib.mkForce false;

  systemd = {
    timers."${serviceConfig.unitName}" = {
      enable = true;
      requiredBy = [ "timers.target" ];
      timerConfig.OnCalendar = serviceConfig.onCalendar;
      timerConfig.Unit = "${serviceConfig.unitName}.service";
    };

    services."${serviceConfig.unitName}" = {
      enable = true;
      after = serviceConfig.afterUnits;
      requires = serviceConfig.requiredUnits;
      path = with pkgs; [
        gitMinimal
        jq
        nix
        nixos-rebuild
        systemd
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script =

        ''
          set -xeuf -o pipefail

          if ! git -C /etc/nixos status >/dev/null 2>&1; then
              # So far, this can fail for two reasons:
              # 1. The Git repository does not exist. In which case, nothing precious
              #    was inside it that I would be sad losing.
              # 2. Sometimes, the Git repository can get corrupted.
              rm -rf /etc/nixos
          fi

          if [[ ! -d /etc/nixos ]]; then
              git clone https://gitlab.com/thefossguy/prathams-nixos.git /etc/nixos
          fi

          git -C /etc/nixos pull --no-rebase

          SECONDS_SINCE_EPOCH="$(date +'%s')"
          LAST_MODIFIED_TIMESTAMP_IN_EPOCH_SECONDS="$(stat -c '%Y' flake.lock)"
          LAST_MODIFIED_TIMESTAMP_IN_MINUTES="$(( $(( SECONDS_SINCE_EPOCH - LAST_MODIFIED_TIMESTAMP_IN_EPOCH_SECONDS )) / 60 ))"
          if [[ "''${LAST_MODIFIED_TIMESTAMP_IN_MINUTES}" -gt 50 ]]; then
              nix flake update --flake /etc/nixos
          else
              echo "Not updating flake.lock to be under GitHub's free rate limit."
          fi

          NIXOS_FLAKE_STORE_PATH="$(nix flake archive --json /etc/nixos 2>/dev/null | jq --raw-output '.path')"
          if echo "''${NIXOS_FLAKE_STORE_PATH}" | grep null; then
              echo 'Could not determine the nix store path for the flake'
              exit 1
          fi

          nixosLatestGenOutPath="$(nix eval --raw "''${NIXOS_FLAKE_STORE_PATH}"#nixosConfigurations.${config.networking.hostName}.config.system.build.toplevel 2>/dev/null || echo 'eval-failed')"
          if [[ "''${nixosLatestGenOutPath}" == 'eval-failed' ]]; then
              echo 'Could not determine the outPath for this NixOS generation'
              exit 1
          fi

          nixosToplevelIsCached="$(nix path-info --refresh --store https://nix-cache.thefossguy.com "''${nixosLatestGenOutPath}" 2>/dev/null || echo 'not-cached')"
          if [[ "''${nixosToplevelIsCached}" == 'not-cached' ]]; then
              echo 'This NixOS generation is not cached, yet'
              exit 1
          fi

          nix build --refresh --no-link --max-jobs 0 "''${nixosLatestGenOutPath}"

          nixos-rebuild boot --show-trace --print-build-logs --flake "''${NIXOS_FLAKE_STORE_PATH}"#${config.networking.hostName}
          sync && sync && sync && sync
        '';
    };
  };
}
