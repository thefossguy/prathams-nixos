{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

lib.mkIf (config.customOptions.displayServer.guiSession == "bspwm") {
  xdg.portal = {
    configPackages = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  services = {
    xserver = {
      windowManager = {
        bspwm = {
          enable = true;
          configFile = "${config.customOptions.userHomeDir}/.config/bspwm/bspwmrc";
          sxhkd.configFile = "${config.customOptions.userHomeDir}/.config/sxhkd/sxhkdrc";
        };
      };

      displayManager = {
        defaultSession = "none+bspwm";

        sddm = {
          enable = true;
          enableHidpi = true;
          settings.General.DisplayServer = "x11-user";
        };
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
