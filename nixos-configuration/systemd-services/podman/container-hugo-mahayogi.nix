{ systemUser, mkContainerService, ... }:

let
  containerImage = "docker.io/klakegg/hugo:ext-debian";
  containerVolumePath = "/home/${systemUser.username}/container-data/volumes/mach";

  containerDescription = "Pratham Patel's documentation website";
  containerName = "hugo-mahayogi";
  unitAfter = [ "container-caddy-vishwambhar.service" ];
  unitWants = [ "container-caddy-vishwambhar.service" ];

  extraExecStart = ''
      --publish 8004:1313 \
        --volume ${containerVolumePath}:/src:U \
        ${containerImage} \
        server --disableFastRender --baseURL https://mach.thefossguy.com/ --appendPort=false --port=1313
  '';

in {
  systemd.user.services."container-${containerName}" =
    mkContainerService { inherit containerDescription containerName extraExecStart unitAfter unitWants; };
}
