{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  customOptions = {
    gpuSupport = [ "nvidia" ];
    enableLocalLLMSupport = true;
  };
}
