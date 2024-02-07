{ config, pkgs, ... }:

{
  imports = [ ./desktop-configuration.nix ];

  # BSPWM on X11
  services.xserver = {
    displayManager = {
      defaultSession = "none+bspwm";
    };

    windowManager = {
      bspwm = {
        enable = true;
        configFile = "/home/pratham/.config/bspwm/bspwmrc";
        sxhkd.configFile = "/home/pratham/.config/sxhkd/sxhkdrc";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    dunst
    feh
    jq
    libnotify # provides notify-send
    lxde.lxsession
    picom
    polybarFull
    rofi
    socat
    wmctrl
    xclip
    xfce.thunar
    xsecurelock
    xsel
  ];
}
