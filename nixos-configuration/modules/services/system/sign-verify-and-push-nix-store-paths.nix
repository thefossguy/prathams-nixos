{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.signVerifyAndPushNixStorePaths;
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
      after = serviceConfig.afterUnits;
      requires = serviceConfig.requiredUnits;

      path = with pkgs; [
        awscli2
        coreutils-full
        findutils
        git
        nix
        python3
      ];

      serviceConfig = {
        User = "root";
        Type = "oneshot";
      };

      preStart = "rm -vf /etc/nixos/result*";

      script = ''
        set -xeuf -o pipefail

        # Using the `--link-outPaths` option in the `scripts/nix-ci/builder.py` script
        # creates a symlink for each expression that is to be built, but is built
        # by the builders and is sent to the local cache. Therefore, it is
        # like building the expressions, even for other `system`s, without
        # actually building it. So instead of signing every store path, sign
        # only the ones that are in /etc/nixos/result*. Reducing the time taken.
        pushd /etc/nixos || exit 1
        python3 ./scripts/nix-ci/builder.py \
            --nixosConfigurations --homeConfigurations --devShells --packages \
            --exclusive-nix-system-aarch64-linux --exclusive-nix-system-x86_64-linux \
            --evaluate-outPaths --link-outPaths
        popd || exit 1

        nixResults=( $(find /etc/nixos -type l | tr '\r\n' ' ' | xargs realpath) )
        nix store sign --recursive --key-file /my-nix-binary-cache/cache-priv-key.pem "''${nixResults[@]}"
        nix store verify --recursive --sigs-needed 1 "''${nixResults[@]}"
        nix copy --to 's3://thefossguy-nix-cache-001-8c0d989b-44cf-4977-9446-1bf1602f0088?region=us-east-1' "''${nixResults[@]}"

        echo -e 'StoreDir: /nix/store\nWantMassQuery: 1\nPriority: 10' | aws s3 cp - s3://thefossguy-nix-cache-001-8c0d989b-44cf-4977-9446-1bf1602f0088/nix-cache-info
        sha512sum /etc/nixos/flake.lock | aws s3 cp - s3://thefossguy-nix-cache-001-8c0d989b-44cf-4977-9446-1bf1602f0088/zeLock
        git -C /etc/nixos rev-parse HEAD | aws s3 cp - s3://thefossguy-nix-cache-001-8c0d989b-44cf-4977-9446-1bf1602f0088/zeHead
      '';
    };
  };
}
