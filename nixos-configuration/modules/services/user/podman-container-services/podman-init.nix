{
  config,
  lib,
  pkgs,
  osConfig ? { },
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.podmanInit;
  appendedPath = import ../../../../../functions/append-to-path.nix {
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
in
lib.mkIf (osConfig.customOptions.podmanContainers.enableHomelabServices or false) {
  home.packages =
    with pkgs;
    [
      ctop
      podman
      podman-compose
      podman-tui
    ]
    ++ lib.optionals (osConfig.customOptions.useMinimalConfig or false) [ buildah ];

  xdg.configFile = {
    "containers/policy.json" = {
      enable = true;
      text = ''
        {
          "default": [
            "type": "insecureAcceptAnything"
          ]
        }
      '';
    };
  };

  systemd.user.services."${serviceConfig.unitName}" = {
    Install = {
      WantedBy = [ "default.target" ];
    };

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
      ExecStart = "/home/${nixosSystemConfig.coreConfig.systemUser.username}/.local/scripts/other-common-scripts/podman-initialization.sh";
    };
  };
}
