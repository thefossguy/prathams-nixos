{ systemUser, mkContainerService, ... }@args:

let
  containerImage = "docker.io/library/caddy:latest";
  containerVolumePath = "/home/${args.nixosSystem.systemUser.username or systemUser.username}/container-data/volumes/caddy";

  containerDescription = "Caddy Web Server (reverse proxy)";
  containerName = "caddy-vishwambhar";
  unitAfter = [ "podman-init.service" ];
  unitRequires = [ "podman-init.service" ];

  extraExecStart = ''
      --publish 8001:80 \
        --publish 8002:443 \
        --volume ${containerVolumePath}/caddy_config:/config:U \
        --volume ${containerVolumePath}/caddy_data:/data:U \
        --volume ${containerVolumePath}/Caddyfile:/etc/caddy/Caddyfile:U \
        --volume ${containerVolumePath}/site:/srv:U \
        --volume ${containerVolumePath}/ssl:/etc/ssl:U \
        ${containerImage} \
        caddy run --config /etc/caddy/Caddyfile
  '';

in {
  systemd.user.services."container-${containerName}" =
    mkContainerService { inherit containerDescription containerName extraExecStart unitAfter unitRequires; };
}
