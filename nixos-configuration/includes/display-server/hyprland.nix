{ lib, pkgs, ... }:

let
  # workaround until https://github.com/NixOS/nixpkgs/pull/331278 is merged
  # and also lands in a stable branch
  origKwalletPamPkg = pkgs.kdePackages.kwallet-pam;
  kwalletPamWithForceRun = origKwalletPamPkg.overrideAttrs {
    postPatch = ''
      ${origKwalletPamPkg.postPatch or ""}
      sed -i 's/static int force_run = 0;/static int force_run = 1;/' pam_kwallet.c
    '';
  };
in

{
  imports = [ ./base-display-server.nix ];

  programs.hyprland.enable = true;
  programs.waybar.enable = true;
  services.hypridle.enable = true;

  security.pam.services.login.kwallet.enable = true;
  security.pam.services.login.kwallet.package = kwalletPamWithForceRun;

  # lightdm gets enabled by default if no display manager is enabled
  # force disable in case I want to login from the TTY instead of using **any** DM
  services.xserver.displayManager.lightdm.enable = lib.mkForce false;

  services.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      enable = true;
      wayland.enable = lib.mkDefault false; # wayland support is experimental
      enableHidpi = true;
    };
  };

  environment.variables = {
    # enables the Wayland trackpad gestures in Chroimum/Electron
    NIXOS_OZONE_WL = "1";
    # since the pam_kwallet_init is not symlinked anywhere (that I could find)
    # put it in an env that can be called from a script
    NIXOS_PAM_KWALLET_INIT_FILE = "${kwalletPamWithForceRun}/libexec/pam_kwallet_init";
  };

  environment.systemPackages = with pkgs; [
    blueman
    brightnessctl # manage the embedded display's brightness
    cliphist
    grim # screenshot utility
    kdePackages.kdeconnect-kde
    kdePackages.kdenlive
    kdePackages.kwalletmanager
    kdePackages.okular # the universal document viewer (good for previews)
    libnotify # for some reason, this isn't bundled with a notification daemon ('mako' in my case)
    mako # notification daemon
    networkmanagerapplet
    playerctl # for play/pause/next/previous using fn-keys
    slurp # screenshot selection utility
    swaylock-fancy
    swww # setting wallpaper
    wayland-utils
    wl-clipboard
    wofi # app launcher
    xfce.thunar # file manager
    xfce.tumbler # thumbnails for thunar
  ];
}
