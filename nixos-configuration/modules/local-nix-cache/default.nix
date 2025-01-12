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
    extra-substituters = [ "http://10.0.0.24" ];
    extra-trusted-public-keys = [ "10.0.0.24:g29fjBRU/VGj6kkIQqjm0o5sxWduZ1hNNLTnSeF/AAU=" ];
  };
}
