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
        curl
        gnugrep
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        set -xeuf -o pipefail

        nixosToplevelOutPath="$(nix eval --raw 2>/dev/null /etc/nixos#nixosConfigurations.${config.networking.hostName}.config.system.build.toplevel || echo 'eval-failed')"
        if [[ "''${nixosToplevelOutPath}" == 'eval-failed' ]]; then
            echo 'Could not determine the outPath for your NixOS toplevel build derivation'
            exit 1
        fi

        if [[ -d "''${nixosToplevelOutPath}" ]]; then
            echo 'The latest NixOS generation is already built, exiting early'
            exit 0
        fi

        ${lib.strings.optionalString (!config.customOptions.localCaching.buildsNixDerivations) ''
          nixosToplevelOutPathHash="$(echo "''${nixosToplevelOutPath}" | cut -c 12-43 || echo 'shouldnt-really-fail')"
          if [[ "''${nixosToplevelOutPathHash}" == 'shouldnt-really-fail' ]]; then
              echo 'Could not determine the hash for the outPath for your NixOS toplevel build derivation'
              exit 1
          fi

          nixosToplevelIsCached="$(curl "https://nix-cache.thefossguy.com/''${nixosToplevelOutPathHash}.narinfo" 2>/dev/null || echo 'curl-failed')"
          if [[ "''${nixosToplevelIsCached}" == 'curl-failed' ]]; then
              echo 'Could not check if the NixOS toplevel derivation is cached or not'
              exit 1
          elif ! echo "''${nixosToplevelIsCached}" | grep -q "''${nixosToplevelOutPathHash}"; then
              echo 'The NixOS toplevel derivation is not cached, yet'
              exit 1
          fi
        ''}

        nixos-rebuild boot --show-trace --print-build-logs --flake /etc/nixos#${config.networking.hostName}
      '';
    };
  };
}
