{ pkgs, systemUser, ... }:

{
  systemd.user.services = {
    "podman-init" = {
      Unit = {
        Description = "Podman initialization";
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
        ExecStart = "${pkgs.nix}/bin/nix-shell /home/${systemUser.username}/.local/scripts/other-common-scripts/podman-initialization.sh";
        Type = "oneshot";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };
  };

  home.packages = with pkgs; [ ctop podman-compose podman-tui ];
}
