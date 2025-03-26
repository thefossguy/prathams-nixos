{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = nixosSystemConfig.extraConfig.allServicesSet.containerTransmission0x0;

  hostPortConfig = {
    peerPortTcp = 8009;
    peerPortUdp = 8010;
    rpcPort = 8011;
  };

  containerConfig' = {
    configDir = "/transmission-daemon";
    downloadIncompleteDir = containerConfig'.configDir + "/downloads/incomplete";
    downloadCompleteDir = containerConfig'.configDir + "/downloads/complete";
    watchDir = containerConfig'.configDir + "/watch";

    ports = {
      peerPort = 51413;
      rpcPort = 9091;
    };

    configFile = pkgs.writeText "settings.json" (builtins.toJSON containerConfig'.configFileContents);
    configFileContents = {
      speed-limit-down = 209716; # 200 MiB/s
      speed-limit-down-enabled = true;
      speed-limit-up = 209716; # 200 MiB/s
      speed-limit-up-enabled = true;

      download-dir = containerConfig'.downloadCompleteDir;
      incomplete-dir = containerConfig'.downloadIncompleteDir;
      incomplete-dir-enabled = true;
      watch-dir = containerConfig'.watchDir;
      watch-dir-enabled = true;
      watch-dir-force-generic = false; # Boolean for if "watch dir" is a network mount
      preallocation = 0; # 0: Off; 1: Fast; 2: Full; 2 is slower but reduces disk fragmentation
      rename-partial-files = true; # Postfix partial files with `.part`
      start-added-torrents = true;

      cache-size-mb = 64;
      dht-enabled = true;
      encryption = 1; # 0: Prefer unencrypted connections; 1: Prefer encrypted connections; 2; Require encrypted connections
      lpd-enabled = false;
      pex-enabled = true;
      scrape-paused-torrents-enabled = true;
      tcp-enabled = true;
      utp-enabled = true;
      torrent-added-verify-mode = "full"; # `fast` or `full`
      sleep-per-seconds-during-verify = 1000;

      bind-address-ipv4 = "0.0.0.0";
      bind-address-ipv6 = "::";

      peer-limit-global = 500;
      peer-limit-per-torrent = 5;
      reqq = 10000;
      sequential_download = false;
      peer-port = containerConfig'.ports.peerPort;
      peer-port-random-on-start = false;
      port-forwarding-enabled = true;

      download-queue-enabled = false;
      queue-stalled-enabled = true;
      queue-stalled-minutes = 1440; # 1 day
      seed-queue-enabled = true;
      seed-queue-size = 500;

      anti-brute-force-enabled = true;
      anti-brute-force-threshold = 3;
      rpc-authentication-required = true;
      rpc-bind-address = "0.0.0.0";
      rpc-enabled = true;
      rpc-username = "transmission";
      # generate one with `transmission-daemon --password $PASSWD` and `grep rpc-password ~/.config/transmission-daemon/settings.json`
      rpc-password = "{932dc3826116a979f3e67014a5fa894085f2a864CzCwMrsx";
      rpc-port = containerConfig'.ports.rpcPort;
      rpc-whitelist = "10.0.0.*";
      rpc-whitelist-enabled = true;
    };
  };

  containerImage = pkgs.dockerTools.buildImage {
    name = serviceConfig.unitName;
    tag = "latest";

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = with pkgs; [ transmission_4 ];

      pathsToLink = [
        "/bin"
        "/sbin"
        "/usr/bin"
        "/usr/sbin"
      ];
    };

    # Equivalent to RUN
    runAsRoot = ''
      #!${pkgs.bash}/bin/bash
      set -xeuf -o pipefail

      mkdir -vp ${containerConfig'.downloadCompleteDir} ${containerConfig'.downloadIncompleteDir} ${containerConfig'.watchDir}
      cp ${containerConfig'.configFile} ${containerConfig'.configDir}/settings.json
    '';

    config = {
      Cmd = [
        "${pkgs.transmission_4}/bin/transmission-daemon"
        "--config-dir"
        containerConfig'.configDir
      ];
      WorkingDir = containerConfig'.configDir;
      Volumes = {
        "${containerConfig'.configDir}" = { };
      };
    };
  };

  containerConfig = {
    inherit containerImage;
    enableAutoUpdates = false;
    network = "containers_default";
    description = serviceConfig.unitName;
    extraExecStart = ''
      --publish ${builtins.toString hostPortConfig.peerPortTcp}:${builtins.toString containerConfig'.ports.peerPort}/tcp \
        --publish ${builtins.toString hostPortConfig.peerPortUdp}:${builtins.toString containerConfig'.ports.peerPort}/udp \
        --publish ${builtins.toString hostPortConfig.rpcPort}:${builtins.toString containerConfig'.ports.rpcPort}/tcp \
        --volume ${config.customOptions.podmanContainers.containersDirPath}/${serviceConfig.unitName}:${containerConfig'.configDir}:U \
        ${serviceConfig.unitName}:latest
    '';

  };
in

lib.mkIf
  (builtins.elem serviceConfig.unitName config.customOptions.podmanContainers.homelabServices)
  {
    home-manager.users."${nixosSystemConfig.coreConfig.systemUser.username}" =
      {
        config,
        lib,
        osConfig,
        pkg,
        pkgsChannels,
        nixosSystemConfig,
        ...
      }:
      {
        systemd.user.services."${serviceConfig.unitName}" =
          import ../../../../functions/make-podman-container-service.nix
            {
              inherit
                lib
                pkgs
                serviceConfig
                containerConfig
                ;
            };
      };

    networking.firewall = {
      allowedTCPPorts = [
        hostPortConfig.peerPortTcp
        hostPortConfig.rpcPort
      ];
      allowedUDPPorts = [
        hostPortConfig.peerPortUdp
      ];
    };
  }
