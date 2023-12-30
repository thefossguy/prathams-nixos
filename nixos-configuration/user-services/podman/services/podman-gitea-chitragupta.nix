{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.services =
    let
      container_name = "gitea-chitragupta";
      container_image = "docker.io/library/postgres:15-bookworm";
      container_volume_path = "$HOME/container-data/volumes/gitea/database";
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
          Description = "Container service for Gitea database (PostgreSQL)";
          Documentation = [ "man:podman-run(1)" "man:podman-stop(1)" "man:podman-rm(1)" ];
          Requires = [ "podman-init.service" ];
          After = [ "podman-init.service" ];
          RequiresMountsFor = [ "%t/containers" ];
        };
        Service = {
          ExecStart = ''
            ${exec_start} \
              --env POSTGRES_USER=gitea \
              --env POSTGRES_PASSWORD=/run/secrets/gitea_database_user_password \
              --env POSTGRES_DB=gitea \
              --secret gitea_database_user_password \
              --volume ${container_volume_path}:/var/lib/postgresql/data:U \
              ${container_image}
          '';
          ExecStop = "${exec_stop}";
          ExecStopPost = "${exec_stop_post}";
          Environment = [ "PODMAN_SYSTEMD_UNIT=%n" ];
          Type = "notify";
          NotifyAccess = "all";
          Restart = "always";
        };
        Install = {
          RequiredBy = [ "container-gitea-govinda.service" ];
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
