{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.services =
    let
      container_name = "caddy-vishwambhar";
      container_image = "docker.io/library/caddy:latest";
      container_volume_path = "/home/pratham/container-data/volumes/caddy";
      exec_start = ''
        ${pkgs.podman}/bin/podman run \
          --cgroups no-conmon \
          --cidfile %t/%n.ctr-id \
          --detach \
          --env TZ=Asia/Kolkata \
          --label io.containers.autoupdate=registry \
          --name ${container_name} \
          --network containers_default \
          --network-alias ${container_name} \
          --pull missing \
          --replace \
          --rm \
          --sdnotify conmon'';
      exec_stop = ''
        ${pkgs.podman}/bin/podman stop \
          --cidfile %t/%n.ctr-id \
          --ignore \
          --time 120
      '';
      exec_stop_post = ''
        ${pkgs.podman}/bin/podman rm \
          --cidfile %t/%n.ctr-id \
          --ignore \
          --time 120 \
          --force
      '';
    in
    {
      "container-${container_name}" = {
        Unit = {
          Description = "Container service for Caddy Web Server (reverse proxy)";
          Documentation = [ "man:podman-run(1)" "man:podman-stop(1)" "man:podman-rm(1)" ];
          Requires = [ "podman-init.service" ];
          After = [ "podman-init.service" ];
          RequiresMountsFor = [ "%t/containers" ];
        };
        Service = {
          ExecStart = ''
            ${exec_start} \
              --publish 8001:80 \
              --publish 8002:443 \
              --volume ${container_volume_path}/caddy_config:/config:U \
              --volume ${container_volume_path}/caddy_data:/data:U \
              --volume ${container_volume_path}/Caddyfile:/etc/caddy/Caddyfile:U \
              --volume ${container_volume_path}/site:/srv:U \
              --volume ${container_volume_path}/ssl:/etc/ssl:U \
              ${container_image} \
              caddy run --config /etc/caddy/Caddyfile
          '';
          ExecStop = "${exec_stop}";
          ExecStopPost = "${exec_stop_post}";
          Environment = [ "PODMAN_SYSTEMD_UNIT=%n" ];
          Type = "notify";
          NotifyAccess = "all";
          Restart = "always";
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
  ];
}
