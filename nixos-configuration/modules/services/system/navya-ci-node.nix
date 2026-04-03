{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.navyaCINode;
in

lib.mkIf config.customOptions.localCaching.buildsNixDerivations {
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
          --nix-system ${config.nixpkgs.hostPlatform.system} \
          --flake-path /etc/nixos \
          --machine-role node \
          --update-lockfile \
          --nix-copy-machine 'ssh-ng://pratham@10.0.0.24?ssh-key=${config.customOptions.userHomeDir}/.ssh/ssh' \
          --copy-unsigned-paths \
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
