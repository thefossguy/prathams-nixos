{ config, lib, pkgs, osConfig ? null, pkgsChannels, nixosSystemConfig, ... }:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.podmanInit;
  appendedPath = import ../../../../../functions/make-podman-container-service.nix {
    packages = with pkgs; [
      bash
      choose
      coreutils
      curl
      findutils
      git
      gnugrep
      openssl
      podman
    ];
  };
in lib.mkIf (osConfig.customOptions.podmanContainers.enableHomelabServices or false) {
  home.packages = with pkgs; [
    #buildah
    ctop
    podman-compose
    podman-tui
  ];

  systemd.user.services."${serviceConfig.unitName}" = {
    Install = { WantedBy = [ "default.target" ]; };

    Unit = {
      Description = "A service to initialize Podman";
      Requires = [ "podman-restart.service" ];
      After = [ "podman-restart.service" ];

      Documentation = [
        "man:openssl-create(1)"
        "man:podman-network-create(1)"
        "man:podman-network-exists(1)"
        "man:podman-secret-create(1)"
        "man:podman-secret-exists(1)"
      ];
    };

    Service = {
      Type = "oneshot";
      Environment = [ appendedPath ];
      ExecStart = "bash /home/${nixosSystemConfig.coreConfig.systemUser.username}/.local/scripts/other-common-scripts/podman-initialization.sh";
    };
  };
}
