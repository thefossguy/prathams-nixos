{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  imports = [ ./default.nix ];
  xdg.portal = {
    configPackages = [ pkgs.libsForQt5.xdg-desktop-portal-kde ];
    extraPortals = [ pkgs.libsForQt5.xdg-desktop-portal-kde ];
  };

  services.xserver = {
    windowManager = {
      bspwm = {
        enable = true;
        configFile = "/home/${systemUser.username}/.config/bspwm/bspwmrc";
        sxhkd.configFile = "/home/${systemUser.username}/.config/sxhkd/sxhkdrc";
      };
    };

    displayManager = {
      defaultSession = "none+bspwm";

      sddm = {
        enable = true;
        enableHidpi = true;
        #autologin = {
        #  enable = true;
        #  user = systemUser.username;
        #};
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
