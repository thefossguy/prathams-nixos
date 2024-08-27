{ pkgs, systemUser, ... }:

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
          configFile = "/home/${nixosSystem.systemUser.username}/.config/bspwm/bspwmrc";
          sxhkd.configFile = "/home/${nixosSystem.systemUser.username}/.config/sxhkd/sxhkdrc";
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
