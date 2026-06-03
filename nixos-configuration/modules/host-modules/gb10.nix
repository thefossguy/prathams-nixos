{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.socSupport.armSoc == "gb10") {
  boot.kernelParams = [
    "console=tty0"
  ];

  customOptions = {
    gpuSupport = [ "nvidia" ];
    enableLocalLLMSupport = true;
  };
}
