{ mkContainerService, ... }:

let
  containerImage = "lscr.io/linuxserver/transmission:latest";
  containerVolumePath = "/trayimurti/torrents";

  containerDescription = "Transmission BitTorrent client";
  containerName = "transmission-raadhe";
  unitAfter = [ "container-caddy-vishwambhar.service" ];
  unitWants = [ "container-caddy-vishwambhar.service" ];

  extraExecStart = ''
      --publish 8009:9091 \
        --publish 8010:5143 \
        --publish 9001:5143/udp \
        --volume ${containerVolumePath}/downloads:/downloads:U \
        --volume ${containerVolumePath}/config:/config:U \
        ${containerImage}
  '';

in {
  systemd.user.services."container-${containerName}" = mkContainerService {
    inherit containerDescription containerName extraExecStart unitAfter unitWants;
  };
}
