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

          nixosLatestGenOutPath="$(nix eval --raw /etc/nixos#nixosConfigurations.${config.networking.hostName}.config.system.build.toplevel 2>/dev/null || echo 'eval-failed')"
          if [[ "''${nixosLatestGenOutPath}" == 'eval-failed' ]]; then
              echo 'Could not determine the outPath for this NixOS generation'
              exit 1
          fi

          nixosToplevelIsCached="$(nix path-info --store https://nix-cache.thefossguy.com "''${nixosLatestGenOutPath}" 2>/dev/null || echo 'not-cached')"
          if [[ "''${nixosToplevelIsCached}" == 'not-cached' ]]; then
              echo 'This NixOS generation is not cached, yet'
              exit 1
          fi

          nix build --no-link --max-jobs 0 "''${nixosLatestGenOutPath}"

          nixos-rebuild boot --show-trace --print-build-logs --flake /etc/nixos#${config.networking.hostName}
        '';
    };
  };
}
