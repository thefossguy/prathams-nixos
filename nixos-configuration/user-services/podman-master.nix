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
          Requires = [ "default.target" ];
          After = [ "default.target" ];
        };
        Service = {
          #Environment = [ "PATH='${pkgs.dash}/bin:${pkgs.podman}/bin:${pkgs.openssl}/bin'" ];
          Environment = [ "PATH='${pkgs.dash}/bin:${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin'" ];
          Type = "oneshot";
          ExecStart = "/home/pratham/.local/scripts/other-common-scripts/podman-initialization.sh";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };

  imports = [
    ./podman-hugo-vaikunthnatham.nix
    ./podman-hugo-mahayogi.nix
    ./podman-uptime-vishnu.nix
    ./podman-transmission-raadhe.nix
    ./podman-gitea-nandini.nix
    #./podman-nextcloud-nandini.nix
  ];
}
