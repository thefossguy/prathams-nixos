{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.services =
    let
      universal_container_path = "/trayimurti/containers/volumes";
      container_name = "caddy-vishwambhar";
    in
    {
      "container-${container_name}" = {
        Unit = {
          Description = "Container service for the reverse proxy";
          Documentation = [ "man:podman-run(1)" "man:podman-stop(1)" "man:podman-rm(1)" ];
          Requires = [ "podman-init.service" ];
          After = [ "podman-init.service" ];
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
              --publish 8001:80 \
              --publish 8002:443 \
              --network-alias ${container_name} \
              --name ${container_name} \
              --volume ${universal_container_path}/caddy/Caddyfile:/etc/caddy/Caddyfile:Z \
              --volume ${universal_container_path}/caddy/site:/srv:Z \
              --volume ${universal_container_path}/caddy/caddy_data:/data:Z \
              --volume ${universal_container_path}/caddy/caddy_config:/config:Z \
              --volume ${universal_container_path}/caddy/ssl:/etc/ssl:Z \
              docker.io/library/caddy:latest \
              caddy run --config /etc/caddy/Caddyfile
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
          Environment = "PODMAN_SYSTEMD_UNIT=%n";
          Type = "notify";
          NotifyAccess = "all";
          Restart = "always";
          TimeoutStopSec = 60;
        };
        Install = {
          WantedBy = [ "podman-init.service" ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    8001 # caddy HTTP
    8002 # caddy HTTPS
  ];
}
