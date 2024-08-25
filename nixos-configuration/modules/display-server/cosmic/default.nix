{ pkgs, ... }:

{
  imports = [ ./base-display-server.nix ];

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # enables the Wayland trackpad gestures in Chroimum/Electron
  environment.variables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [];
}
