{
  allInputChannels,
  mkPkgs,
  system,
  systemUser,
  nixpkgsChannel ? "default",
  nixBuildArgs,
}:
let
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
    stableSmall = mkPkgs {
      inherit system;
      passedNixpkgs = allInputChannels.stableSmall.nixpkgs;
    };
    unstableSmall = mkPkgs {
      inherit system;
      passedNixpkgs = allInputChannels.unstableSmall.nixpkgs;
    };
  };

  nixosSystemConfig = {
    coreConfig = {
      inherit system systemUser;
      isNixOS = false;
    };
    extraConfig = {
      systemType = "server";
      allServicesSet = import ./all-services-set.nix {
        systemType = nixosSystemConfig.extraConfig.systemType;
        systemUserUsername = nixosSystemConfig.coreConfig.systemUser.username;
      };
      inherit inputChannel nixBuildArgs;
    };
  };
in
nixosSystemConfig.extraConfig.inputChannel.homeManager.lib.homeManagerConfiguration {
  pkgs = pkgsChannels.pkgs;
  # nix eval .#homeConfigurations."${nixosSystemConfig.coreConfig.system}"."${nixosSystemConfig.coreConfig.systemUser.username}".options._module.specialArgs.value.nixosSystemConfig
  extraSpecialArgs = { inherit pkgsChannels nixosSystemConfig; };
  modules = [ ../nixos-configuration/modules/home-manager/non-nixos-home.nix ];
}
