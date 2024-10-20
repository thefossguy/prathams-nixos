{ config, lib, pkgs, ... }:

lib.mkIf (config.custom-options.isNixCacheMachine or false) {
  services.nix-serve = {
    enable = true;
    openFirewall = true;
    port = 5000;
    secretKeyFile = "/my-nix-binary-cache/cache-priv-key.pem";
    package = pkgs.nix-serve-ng;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "nixcache.chaturvyas.localhost" = {
        locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
      };
    };
  };
}
