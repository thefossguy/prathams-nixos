{ config, lib, ... }:

lib.mkIf (config.services.xserver.enable) {
  services.xserver.videoDrivers = lib.mkBefore [
    "modesetting" # Prefer the modesetting driver in X11
    "fbdev" # Fallback to fbdev
  ];
}
