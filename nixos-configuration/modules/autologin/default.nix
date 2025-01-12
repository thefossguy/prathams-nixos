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
    ./getty-autologin.nix
    ./guisesssion-autologin.nix
  ];
}
