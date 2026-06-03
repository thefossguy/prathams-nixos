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

  # `nvidia-smi --query-gpu=compute_cap`
  nixpkgs.config.cudaCapabilities = [ "12.1" ];

  environment.systemPackages = with pkgs; [
    cudaPackages.cuda_nvcc
  ];

  customOptions = {
    gpuSupport = [ "nvidia" ];
    enableLocalLLMSupport = true;
  };
}
