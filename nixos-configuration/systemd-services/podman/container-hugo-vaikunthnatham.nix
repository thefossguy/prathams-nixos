{ config
, lib
, pkgs
, systemUser
, mkContainerService
, ...
}:

let
  containerImage = "docker.io/klakegg/hugo:ext-debian";
  containerVolumePath = "/home/${systemUser.username}/container-data/volumes/blog";

  containerDescription = "Pratham Patel's personal blog";
  containerName = "hugo-vaikunthnatham";
  unitAfter = [ "container-caddy-vishwambhar.service" ];
  unitWants = [ "container-caddy-vishwambhar.service" ];

  extraExecStart = ''
      --publish 8003:1313 \
        --volume ${containerVolumePath}:/src:U \
        ${containerImage} \
        server --disableFastRender --baseURL https://blog.thefossguy.com/ --appendPort=false --port=1313
  '';
in

{
  systemd.user.services."container-${containerName}" = mkContainerService {
    inherit containerDescription containerName extraExecStart unitAfter unitWants;
  };
}
