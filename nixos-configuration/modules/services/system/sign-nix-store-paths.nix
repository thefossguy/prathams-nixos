{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.signNixStorePaths;
in
lib.mkIf config.customOptions.localCaching.servesNixDerivations {
  systemd = {
    timers."${serviceConfig.unitName}" = {
      enable = true;
      requiredBy = [ "timers.target" ];
      timerConfig.OnCalendar = serviceConfig.onCalendar;
      timerConfig.Unit = "${serviceConfig.unitName}.service";
    };

    services."${serviceConfig.unitName}" = {
      enable = true;
      path = with pkgs; [
        nix
        python3
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      script = ''
        # Using the `--link-only` option in the `scripts/nix-ci/builder.py` script
        # creates a symlink for each expression that is to be built, but is built
        # by the builders and is sent to the local cache. Therefore, it is
        # like building the expressions, even for other `system`s, without
        # actually building it. So instead of signing every store path, sign
        # only the ones that are in /etc/nixos/result*. Reducing the time taken.
        pushd /etc/nixos || exit 1
        rm -vf result*
        python3 ./scripts/nix-ci/builder.py --use-emulation --link-only --nixosConfigurations --homeConfigurations --devShells --packages
        nix store sign --recursive --key-file /my-nix-binary-cache/cache-priv-key.pem /etc/nixos/result*
        popd || exit 0
      '';
    };
  };
}
