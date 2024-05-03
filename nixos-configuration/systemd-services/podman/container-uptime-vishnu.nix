{ config
, lib
, pkgs
, systemUser
, mkContainerService
, ...
}:

let
  containerImage = "docker.io/louislam/uptime-kuma:debian";
  containerVolumePath = "/home/${systemUser.username}/container-data/volumes/uptimekuma";

  containerDescription = "Uptime Kuma";
  containerName = "uptime-vishnu";
  unitAfter = [ "container-caddy-vishwambhar.service" ];
  unitWants = [ "container-caddy-vishwambhar.service" ];

  extraExecStart = ''
      --publish 8008:3001 \
        --volume ${containerVolumePath}:/app/data:U \
        ${containerImage}
  '';
in

{
  systemd.user.services."container-${containerName}" = mkContainerService {
    inherit containerDescription containerName extraExecStart unitAfter unitWants;
  };
}
