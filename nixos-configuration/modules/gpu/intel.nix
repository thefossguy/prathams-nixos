{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf (builtins.elem "intel" config.customOptions.gpuSupport) {
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  services.xserver.videoDrivers =
    if ((builtins.elemAt config.customOptions.gpuSupport 0) == "intel") then
      (lib.mkBefore [ "modesetting" ])
    else
      [ "modesetting" ];

  hardware = {
    enableRedistributableFirmware = lib.mkForce true;
    intel-gpu-tools.enable = true;
    graphics = {
      extraPackages = with pkgs; [
        #intel-compute-runtime # not really necessary unless OpenCL is in use
        intel-media-driver
        intel-vaapi-driver
        vpl-gpu-rt
      ];
    };
  };
}
