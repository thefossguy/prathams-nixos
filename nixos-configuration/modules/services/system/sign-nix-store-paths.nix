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
        coreutils-full
        findutils
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
        python3 ./scripts/nix-ci/builder.py --link-only --nixosConfigurations --homeConfigurations --devShells --packages --exclusive-nix-system-aarch64-linux --exclusive-nix-system-x86_64-linux
        popd || exit 1

        nix store sign --recursive --key-file /my-nix-binary-cache/cache-priv-key.pem $(find /etc/nixos -type l | tr '\r\n' ' ' | xargs realpath)
      '';
    };
  };
}
