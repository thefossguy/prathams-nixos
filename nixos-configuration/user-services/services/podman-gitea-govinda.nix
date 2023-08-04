{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.services =
    let
      container_name = "gitea-govinda";
      container_image = "docker.io/gitea/gitea:latest";
      container_volume_path = "/home/pratham/container-data/volumes/gitea";
      db_container_service = "container-gitea-chitragupta.service";
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
          Description = "Container service for Gitea web UI";
          Documentation = [ "man:podman-run(1)" "man:podman-stop(1)" "man:podman-rm(1)" ];
          Requires = [ "${db_container_service}" ];
          Wants = [ "container-caddy-vishwambhar.service" ];
          After = [ "${db_container_service}" "container-caddy-vishwambhar.service" ];
          RequiresMountsFor = [ "%t/containers" ];
        };
        Service = {
          ExecStart = ''
            ${exec_start} \
              --env DEFAULT_BRANCH=master \
              --env DISABLE_SSH=false \
              --env DOMAIN=git.thefossguy.com \
              --env GITEA__database__DB_TYPE=postgres \
              --env GITEA__database__HOST=gitea-chitragupta:5432 \
              --env GITEA__database__NAME=gitea \
              --env GITEA__database__PASSWD=/run/secrets/gitea_database_user_password \
              --env GITEA__database__USER=gitea \
              --env GITEA__service__DISABLE_REGISTRATION=true \
              --env ROOT_URL=https://git.thefossguy.com \
              --env RUN_MODE=prod \
              --env SSH_DOMAIN=git.thefossguy.com \
              --env SSH_LISTEN_PORT=22 \
              --env SSH_PORT=22 \
              --env START_SSH_SERVER=true \
              --secret gitea_database_user_password \
              --publish 8005:3000 \
              --publish 8006:22 \
              --volume ${container_volume_path}/web:/data:U \
              --volume ${container_volume_path}/ssh:/data/git/.ssh:U \
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
          WantedBy = [ "default.target" ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    8005 # Gitea web UI
    8006 # Gitea SSH
  ];

  imports = [
    ./podman-caddy-vishwambhar.nix
    ./podman-gitea-chitragupta.nix
  ];
}
