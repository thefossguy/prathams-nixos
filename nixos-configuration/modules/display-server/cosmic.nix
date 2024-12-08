{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf (config.customOptions.displayServer.guiSession == "cosmic") {
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  nix.extraOptions = ''
    extra-substituters = "https://cosmic.cachix.org"
    extra-trusted-public-keys = "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
  '';

  environment.systemPackages = with pkgs; [
  ];
}
