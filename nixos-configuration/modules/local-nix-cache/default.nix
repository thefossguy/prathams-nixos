{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

{
  imports = [
    ./builder.nix
    ./server.nix
  ];

  nix.settings = {
    extra-substituters = lib.optionals (!config.customOptions.localCaching.servesNixDerivations) [
      "${lib.strings.optionalString nixosSystemConfig.extraConfig.canAccessMyNixCache "http://10.0.0.24"}"
    ];
    extra-trusted-public-keys = [ "10.0.0.24:g29fjBRU/VGj6kkIQqjm0o5sxWduZ1hNNLTnSeF/AAU=" ];
  };
}
