{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  isBuilder = config.customOptions.localCaching.buildsNixDerivations;

  localCachePriority = "?priority=20";
  nixosCachePriority = "?priority=40";

  aarch64Linux = {
    substituters = "http://10.0.0.24${localCachePriority}";
    trustedPublicKeys = "10.0.0.24:g29fjBRU/VGj6kkIQqjm0o5sxWduZ1hNNLTnSeF/AAU=";
  };

  # Don't let the snake eat it's own tail.
  nixSubstituters = if isBuilder then [] else [
    aarch64Linux.substituters
  ];
  nixTrustedPublicKeys = if isBuilder then [] else [
    aarch64Linux.trustedPublicKeys
  ];
in
{
  imports = [
    ./builder.nix
    ./server.nix
  ];

  nix.settings = {
    substituters = lib.mkForce (nixSubstituters
    ++ [ "https://cache.nixos.org${nixosCachePriority}" ]
    );

    trusted-public-keys = lib.mkForce (nixTrustedPublicKeys
    ++ [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ]
    );
  };
}
