{ config
, lib
, pkgs
, osConfig
, systemUser
, mkContainerService
, ...
}:

let
  containerImage = "docker.io/gitea/gitea:latest";
  containerVolumePath = "/home/${systemUser.username}/container-data/volumes/gitea";

  containerDescription = "Gitea web UI";
  containerName = "gitea-govinda";
  unitAfter = unitRequires ++ unitWants;
  unitRequires = [ "container-gitea-chitragupta.service" ];
  unitWants = [ "container-caddy-vishwambhar.service" ];

  extraExecStart = ''
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
        --volume ${containerVolumePath}/web:/data:U \
        --volume ${containerVolumePath}/ssh:/data/git/.ssh:U \
        ${containerImage}
  '';
in

lib.mkIf (osConfig.networking.hostName == "reddish") {
  systemd.user.services."container-${containerName}" = mkContainerService {
    inherit containerDescription containerName extraExecStart unitAfter unitRequires unitWants;
  };
}
