{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf config.customOptions.localCaching.servesNixDerivations {
  environment.systemPackages = with pkgs; [
    awscli2
  ];

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
      "nixcache.${config.networking.hostName}.localhost" = {
        locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
      };
    };
  };
}
