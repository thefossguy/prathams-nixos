{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

lib.mkIf config.customOptions.localCaching.buildsNixDerivations {
  nix = {
    extraOptions = ''
      keep-env-derivations = true
      keep-going = true
    '';

    settings = {
      keep-derivations = true;
      keep-outputs = true;
    };
  };
}
