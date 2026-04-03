{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.navyaCIServer;
in

lib.mkIf config.customOptions.localCaching.servesNixDerivations {
  systemd.services."${serviceConfig.unitName}" = {
    enable = true;
    after = serviceConfig.afterUnits;
    requires = serviceConfig.requiredUnits;
    wantedBy = serviceConfig.wantedByUnits;

    path = with pkgs; [
      git
      nix
      openssh
      openssl
    ];

    serviceConfig = {
      User = "root";
      Type = "simple";
      Restart = "always";
      RestartSec = "10";
    };

    preStart = "touch /etc/nixos/flake.lock";
    script = ''
      ${pkgs.navya-ci}/bin/navya-ci \
          --nix-system aarch64-linux \
          --nix-system x86_64-linux \
          --flake-path /etc/nixos \
          --machine-role server \
          --update-lockfile \
          ${
            lib.strings.optionalString (config.networking.hostName == "chaturvyas") "--nix-copy-machine 'ssh-ng://pratham@hans'"
          } \
          ${
            lib.strings.optionalString (
              config.networking.hostName == "chaturvyas"
            ) "--signing-key-path /my-nix-binary-cache/cache-priv-key.pem"
          } \
          --sleep-break 300 \
          --flake-output-to-build devShells \
          --flake-output-to-build homeConfigurations \
          --flake-output-to-build isoImagesUncompressed \
          --flake-output-to-build kexecTree \
          --flake-output-to-build nixosConfigurations \
          --flake-output-to-build packages \
          #EOF
    '';
  };
}
