{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.services =
    let
      container_name = "hugo-mahayogi";
      container_image = "docker.io/klakegg/hugo:ext-debian";
      container_volume_path = "/home/pratham/container-data/volumes/mach";
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
          --force && \
          rm -rf ${container_volume_path}/resources
      '';
    in
    {
      "container-${container_name}" = {
        Unit = {
          Description = "Container service for Pratham Patel's documentation website";
          Documentation = [ "man:podman-run(1)" "man:podman-stop(1)" "man:podman-rm(1)" ];
          Wants = [ "container-caddy-vishwambhar.service" ];
          After = [ "container-caddy-vishwambhar.service" ];
          RequiresMountsFor = [ "%t/containers" ];
        };
        Service = {
          ExecStart = ''
            ${exec_start} \
              --publish 8004:1313 \
              --volume ${container_volume_path}:/src:U \
              ${container_image} \
              server --disableFastRender --baseURL https://mach.thefossguy.com/ --appendPort=false --port=1313
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
    8004 # machine-setup/documentation blog
  ];

  imports = [
    ./podman-caddy-vishwambhar.nix
  ];
}
