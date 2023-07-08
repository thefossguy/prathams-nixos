{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.services =
    let
      universal_container_path = "/trayimurti/containers/volumes";
      web_container_name = "gitea-govinda";
      db_container_name = "gitea-chitragupta";
    in
    {
      "container-${db_container_name}" = {
        Unit = {
          Description = "Container service for Gitea's database (PGSQL)";
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
              --secret gitea_database_user_password \
              --network-alias ${db_container_name} \
              --name ${db_container_name} \
              --volume ${universal_container_path}/gitea/database:/var/lib/postgresql/data:Z \
              docker.io/library/postgres:15-alpine
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
          RequiredBy = [ "container-${web_container_name}.service" ];
        };
      };
      "container-${web_container_name}" = {
        Unit = {
          Description = "Container service for Gitea";
          Documentation = [ "man:podman-run(1)" "man:podman-stop(1)" "man:podman-rm(1)" ];
          Requires = [ "container-${db_container_name}.service" ];
          After = [ "container-caddy-vishwambhar.service" "container-${web_container_name}.service" ];
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
              --env DEFAULT_BRANCH=master \
              --env RUN_MODE=prod \
              --env DISABLE_SSH=false \
              --env START_SSH_SERVER=true \
              --env SSH_PORT=22 \
              --env SSH_LISTEN_PORT=22 \
              --env ROOT_URL=https://git.thefossguy.com \
              --env DOMAIN=git.thefossguy.com \
              --env SSH_DOMAIN=git.thefossguy.com \
              --env GITEA__database__DB_TYPE=postgres \
              --env GITEA__database__HOST=${db_container_name}:5432 \
              --env GITEA__database__NAME=gitea \
              --env GITEA__database__USER=gitea \
              --env GITEA__service__DISABLE_REGISTRATION=true \
              --secret gitea_database_user_password \
              --publish 8005:3000 \
              --publish 8006:22 \
              --network-alias ${web_container_name} \
              --name ${web_container_name} \
              --volume ${universal_container_path}/gitea/web:/data:Z \
              --volume ${universal_container_path}/gitea/ssh:/data/git/.ssh:Z \
              docker.io/gitea/gitea:latest
              #--env GITEA__database__PASSWD=/run/secrets/gitea_database_user_password \
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

  networking.firewall.allowedTCPPorts = [
    8005 # Gitea web UI
    8006 # Gitea SSH
  ];

  imports = [
    ./podman-caddy-vishwambhar.nix
  ];
}
