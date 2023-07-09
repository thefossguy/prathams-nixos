{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.services =
    let
      universal_container_path = "/trayimurti/containers/volumes";
      container_name = "hugo-mahayogi";
    in
    {
      "container-${container_name}" = {
        Unit = {
          Description = "Container service for Pratham Patel's documentation website'";
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
              --volume ${universal_container_path}/mach:/src \
              --label io.containers.autoupdate=registry \
              --net containers_default \
              --pull newer \
              --publish 8004:1313 \
              --network-alias ${container_name} \
              --name ${container_name} \
              docker.io/klakegg/hugo:debian \
              server --disableFastRender --baseURL https://mach.thefossguy.com/ --appendPort=false --port=1313
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

  networking.firewall.allowedTCPPorts = [ 8004 ];

  imports = [
    ./podman-caddy-vishwambhar.nix
  ];
}
