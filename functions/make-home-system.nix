{ allInputChannels, mkPkgs, system, systemUser, nixpkgsChannel ? "default", nixBuildArgs }:
let
  allServicesSet = import ./all-services-set.nix { systemType = nixosSystemConfig.extraConfig.systemType; };
  inputChannel = allInputChannels."${nixpkgsChannel}";
  pkgsChannels = {
    pkgs = mkPkgs {
      inherit system;
      passedNixpkgs = inputChannel.nixpkgs;
    };
    stable = mkPkgs {
      inherit system;
      passedNixpkgs = allInputChannels.stable.nixpkgs;
    };
    unstable = mkPkgs {
      inherit system;
      passedNixpkgs = allInputChannels.unstable.nixpkgs;
    };
  };

  nixosSystemConfig = {
    coreConfig = {
      inherit system systemUser;
      isNixOS = false;
    };
    extraConfig = {
      inherit inputChannel allServicesSet nixBuildArgs;
    };
  };
in nixosSystemConfig.extraConfig.inputChannel.homeManager.lib.homeManagerConfiguration {
  pkgs = pkgsChannels.pkgs;
  # nix eval .#homeConfigurations."${nixosSystemConfig.coreConfig.system}"."${nixosSystemConfig.coreConfig.systemUser.username}".options._module.specialArgs.value.nixosSystemConfig
  extraSpecialArgs = { inherit pkgsChannels nixosSystemConfig; };
  modules = [ ../nixos-configuration/modules/home-manager/non-nixos-home.nix ];
}
