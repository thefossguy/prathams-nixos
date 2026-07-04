{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  binaryCacheIface = "127.0.0.1";
  binaryCachePort = "5000";
in

lib.mkIf config.customOptions.localCaching.servesNixDerivations {
  services.harmonia = {
    cache = {
      enable = true;
      settings = {
        priority = 10;
        enable_compression = true;
        bind = "${binaryCacheIface}:${binaryCachePort}";
        workers = 4; # all my machines have at least 4 cores.
        max_connection_rate = 256;
      };
    };
    daemon = {
      enable = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  services.nginx = lib.mkIf (config.networking.hostName != "hans") {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "nixcache.${config.networking.hostName}.localhost" = {
        locations."/".proxyPass = "http://${binaryCacheIface}:${binaryCachePort}";
      };
    };
  };
}
