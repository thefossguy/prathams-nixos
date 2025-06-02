{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  isCaddyServerEnabled = config.systemd.services.caddy-server.enable or false;
in

lib.mkIf config.customOptions.localCaching.servesNixDerivations {
  environment.systemPackages = with pkgs; [
    awscli2
  ];

  services.nix-serve = {
    enable = true;
    openFirewall = false; # Handled by Nginx
    port = 5000;
    secretKeyFile = "/my-nix-binary-cache/cache-priv-key.pem";
    extraParams = "--priority 10";
    package = pkgs.nix-serve-ng;
  };

  networking.firewall.allowedTCPPorts = lib.optionals isCaddyServerEnabled [ 80 ];

  services.nginx = {
    enable = !isCaddyServerEnabled;
    recommendedProxySettings = true;
    virtualHosts = {
      "nixcache.${config.networking.hostName}.localhost" = {
        locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
      };
    };
  };
}
