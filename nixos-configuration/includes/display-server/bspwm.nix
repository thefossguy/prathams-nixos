{ config
, lib
, pkgs
, systemUser
, ...
}:

{
  imports = [ ./base-display-server.nix ];

  xdg.portal = {
    configPackages = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  services = {
    xserver = {
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
        settings.General.DisplayServer = "x11-user";
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
    ksnip
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
