{ lib, config, ... }:
let
  aarch64CacheAddr = "10.0.0.24";

  # Do not override the binary cache substitution configuration if the
  # host machine itself is the one providing the nix binary + mirror cache
  additionalNixCaches = {
    substituters = if (config.custom-options.isNixCacheMachine or false) then [] else [
      "http://${aarch64CacheAddr}?priority=10"
    ];
    trusted-public-keys = if (config.custom-options.isNixCacheMachine or false) then [] else [
      "${aarch64CacheAddr}:g29fjBRU/VGj6kkIQqjm0o5sxWduZ1hNNLTnSeF/AAU="
    ];
  };
in {
  nix.settings = {
    substituters = lib.mkForce (
      additionalNixCaches.substituters
      ++ [ "https://cache.nixos.org?priority=100" ] # cache.nixos.org fallback
    );
    trusted-public-keys = lib.mkForce (
      additionalNixCaches.trusted-public-keys
      ++ ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="] # cache.nixos.org fallback
    );
  };
}
