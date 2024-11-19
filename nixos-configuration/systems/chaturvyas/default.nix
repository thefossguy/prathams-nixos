{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  customOptions.localCaching.servesNixDerivations = true;
  customOptions.localCaching.buildsNixDerivations = true;
}
