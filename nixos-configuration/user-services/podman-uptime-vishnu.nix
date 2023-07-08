{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.services =
    let
      universal_container_path = "/trayimurti/containers/volumes";
    in
    {
      "container-uptime-vishnu" = {
        Unit = {
          Description = "Container service for Uptime Kuma";
          Documentation = [ "man:podman-run(1)" "man:podman-stop(1)" "man:podman-rm(1)" ];
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
              --publish 8008:3001 \
              --network-alias uptime-vishnu \
              --name uptime-vishnu \
              --volume ${universal_container_path}/uptimekuma:/app/data:Z \
              docker.io/louislam/uptime-kuma:debian
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
          WantedBy = [ "default.target" ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8008 ];

  imports = [
    ./podman-caddy-vishwambhar.nix
  ];
}
