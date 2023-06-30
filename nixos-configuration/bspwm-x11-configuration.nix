{ config, pkgs, ... }:

{
  # BSPWM on X11
  services.xserver = {
    displayManager = {
      defaultSession = "bspwm";
    };

    windowManager = {
      bspwm = {
        enable = true;
        configFile = "/home/pratham/.config/bspwm/bspwmrc";
        sxhkd.configFile = "/home/pratham/.config/sxhkd/sxhkdrc";
      };
    };
  };
}
