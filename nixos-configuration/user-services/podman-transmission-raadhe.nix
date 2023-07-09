{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.services =
    let
      universal_container_path = "/trayimurti";
      container_name = "transmission-raadhe";
    in
    {
      "container-${container_name}" = {
        Unit = {
          Description = "Container service for Transmission web server";
          Documentation = [ "man:podman-run(1)" "man:podman-stop(1)" "man:podman-rm(1)" ];
          Wants = [ "container-caddy-vishwambhar.service" ];
          After = [ "container-caddy-vishwambhar.service" ];
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
              --publish 8009:9091 \
              --publish 8010:51413 \
              --publish 8011:51413/udp \
              --network-alias ${container_name} \
              --name ${container_name} \
              --volume ${universal_container_path}/torrents/downloads:/downloads \
              --volume ${universal_container_path}/torrents/config:/config \
              lscr.io/linuxserver/transmission:latest
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
