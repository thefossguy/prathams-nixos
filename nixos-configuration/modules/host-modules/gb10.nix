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

  hardware.nvidia = {
    branch = "latest";
    powerManagement.enable = false;
  };

  environment.systemPackages = with pkgs; [
    cudaPackages.cuda_nvcc
    convertSafetensorsToGGUF
  ];

  networking.networkmanager.unmanaged = [
    "interface-name:enp1s0f0np0"
    "interface-name:enP2p1s0f0np0"
    "interface-name:enp1s0f1np1"
    "interface-name:enP2p1s0f1np1"
  ];

  services.openssh.settings.AllowTcpForwarding = lib.mkOverride 20 "local";

  customOptions = {
    gpuSupport = [ "nvidia" ];
    enableLocalLLMSupport = true;
  };
}
