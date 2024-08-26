{ systemUser, mkContainerService, ... }:

let
  containerImage = "docker.io/library/postgres:15-bookworm";
  containerVolumePath = "/home/${systemUser.username}/container-data/volumes/gitea/database";

  containerDescription = "Gitea database (PostgreSQL)";
  containerName = "gitea-chitragupta";
  unitAfter = [ "podman-init.service" ];
  unitRequires = [ "podman-init.service" ];
  installServiceRequiredBy = [ "container-gitea-govinda.service" ];

  extraExecStart = ''
      --env POSTGRES_USER=gitea \
        --env POSTGRES_PASSWORD=/run/secrets/gitea_database_user_password \
        --env POSTGRES_DB=gitea \
        --secret gitea_database_user_password \
        --volume ${containerVolumePath}:/var/lib/postgresql/data:U \
        ${containerImage}
  '';

in {
  systemd.user.services."container-${containerName}" = mkContainerService {
    inherit containerDescription containerName extraExecStart unitAfter unitRequires installServiceRequiredBy;
  };
}
