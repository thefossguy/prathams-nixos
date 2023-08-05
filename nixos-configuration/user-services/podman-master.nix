{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.services = {
      "podman-init" = {
        Unit = {
          Description = "Podman initialization";
          Documentation = [
            "man:podman-secret-exists(1)"
            "man:podman-secret-create(1)"
            "man:openssl-create(1)"
            "man:podman-network-exists(1)"
            "man:podman-network-create(1)"
          ];
          Requires = [ "podman-restart.service" ];
          After = [ "podman-restart.service" ];
        };
        Service = {
          ExecStart = "/home/pratham/.local/scripts/other-common-scripts/podman-initialization.sh";
          Environment = [ "\"PATH=${pkgs.nix}/bin\"" ];
          Type = "oneshot";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };

  imports = [
    ./services/podman-gitea-chitragupta.nix
    ./services/podman-gitea-govinda.nix
    ./services/podman-hugo-mahayogi.nix
    ./services/podman-hugo-vaikunthnatham.nix
    ./services/podman-transmission-raadhe.nix
    ./services/podman-uptime-vishnu.nix
  ];
}
