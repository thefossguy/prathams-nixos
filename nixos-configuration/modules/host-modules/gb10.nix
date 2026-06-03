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

  environment.systemPackages = with pkgs; [
    cudaPackages.cuda_nvcc
  ];

  customOptions = {
    gpuSupport = [ "nvidia" ];
    enableLocalLLMSupport = true;
  };
}
