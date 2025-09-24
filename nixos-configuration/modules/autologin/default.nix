{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  imports = [
    ./getty-autologin.nix
    ./guisesssion-autologin.nix
  ];
}
