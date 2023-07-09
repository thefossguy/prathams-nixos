{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.services =
    let
      universal_container_path = "/trayimurti/containers/volumes";
      container_name = "";
    in
    {
      "container-${container_name}" = {
        Unit = {
          Description = "Container service for ";
          Documentation = [ "man:podman-run(1)" "man:podman-stop(1)" "man:podman-rm(1)" ];
          Wants = []; # put "container-caddy-vishwambhar.service" here if it is a web service
          After = []; # otherwise, depend on "podman-init.service"
          RequiresMountsFor = "%t/containers";
        };
        Service = {
          ExecStart = ''
            ${pkgs.podman}/bin/podman run \
              --cidfile %t/%n.ctr-id \
              --cgroups no-conmon \
              --sdnotify conmon \
              --rm \
              --replace \
              --detach \
              --env TZ=Asia/Kolkata \
              --label io.containers.autoupdate=registry \
              --net containers_default \
              --pull newer \

              --secret \
              --publish \
              --network-alias ${container_name} \
              --name ${container_name} \
              --volume \
          '';
          ExecStop = ''
            ${pkgs.podman}/bin/podman stop \
              --cidfile %t/%n.ctr-id \
              --ignore \
              --time 10
          '';
          ExecStopPost = ''
            ${pkgs.podman}/bin/podman rm \
              --cidfile %t/%n.ctr-id \
              --ignore \
              --time 10 \
              --force
          '';
          Environment = [ "PODMAN_SYSTEMD_UNIT=%n" ];
          Type = "notify";
          NotifyAccess = "all";
          Restart = "always";
          TimeoutStopSec = 60;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    8001 # caddy HTTP
    8002 # caddy HTTPS
    8003 # personal blog
    8004 # machine-setup/documentation blog
    8005 # Gitea web UI
    8006 # Gitea SSH
    8007 # Nextcloud web UI
    8008 # Uptime Kuma web UI
    8009 # Transmission web UI
    8010 # Transmission torrent comm port (TCP)
  ];
  networking.firewall.allowedUDPPorts = [
    8011 # Transmission torrent comm port (UDP)
  ];

  imports = [
    ./podman-caddy-vishwambhar.nix
  ];
}
