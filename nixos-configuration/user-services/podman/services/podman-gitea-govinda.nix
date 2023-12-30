{ ... }:

{
  home-manager.users.pratham = { pkgs, ... }: {
    systemd.user.services =
    let
      container_name = "gitea-govinda";
      container_image = "docker.io/gitea/gitea:latest";
      container_volume_path = "$HOME/container-data/volumes/gitea";
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
              --env GITEA__actions__ENABLED=false \
              --env GITEA__cron__ENABLED=true \
              --env GITEA__cron__RUN_AT_START=true \
              --env GITEA__database__DB_TYPE=postgres \
              --env GITEA__database__HOST=gitea-chitragupta:5432 \
              --env GITEA__database__NAME=gitea \
              --env GITEA__database__PASSWD=/run/secrets/gitea_database_user_password \
              --env GITEA__database__USER=gitea \
              --env GITEA__openid__ENABLE_OPENID_SIGNIN=false \
              --env GITEA__openid__ENABLE_OPENID_SIGNUP=false \
              --env GITEA__repository__DEFAULT_BRANCH=master \
              --env GITEA__repository__DEFAULT_PRIVATE=public \
              --env GITEA__repository__DEFAULT_PUSH_CREATE_PRIVATE=false \
              --env GITEA__repository__DEFAULT_REPO_UNITS="repo.code,repo.releases" \
              --env GITEA__RUN_MODE=prod \
              --env GITEA__security__LOGIN_REMEMBER_DAYS=14 \
              --env GITEA__server__DISABLE_SSH=false \
              --env GITEA__server__DOMAIN=git.thefossguy.com \
              --env GITEA__server__ROOT_URL=https://git.thefossguy.com \
              --env GITEA__server__SSH_DOMAIN=git.thefossguy.com \
              --env GITEA__server__SSH_EXPOSE_ANONYMOUS=true \
              --env GITEA__server__SSH_LISTEN_PORT=3001 \
              --env GITEA__server__SSH_PORT=22 \
              --env GITEA__server__START_SSH_SERVER=true \
              --env GITEA__service__DEFAULT_KEEP_EMAIL_PRIVATE=true \
              --env GITEA__service__DISABLE_REGISTRATION=true \
              --secret gitea_database_user_password \
              --publish 8005:3000 \
              --publish 8006:3001 \
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
