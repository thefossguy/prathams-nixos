{
  nixpkgs,
  home-manager,
  nixpkgs-stable,
  system,
  systemUser,
  nixBuildArgs,
}:
let
  stablePkgs = nixpkgs-stable.legacyPackages.${system};
  nixosSystemConfig = {
    coreConfig = {
      inherit system systemUser;
      isNixOS = false;
    };
    extraConfig = {
      systemType = "server";
      canAccessMyNixCache = false;
      allServicesSet = import ./all-services-set.nix {
        systemType = nixosSystemConfig.extraConfig.systemType;
        systemUserUsername = nixosSystemConfig.coreConfig.systemUser.username;
      };
      inherit nixpkgs nixBuildArgs;
    };
  };
in
home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.${system};
  # nix eval .#homeConfigurations."${nixosSystemConfig.coreConfig.system}"."${nixosSystemConfig.coreConfig.systemUser.username}".options._module.specialArgs.value.nixosSystemConfig
  extraSpecialArgs = { inherit stablePkgs nixosSystemConfig; };
  modules = [ ../nixos-configuration/modules/home-manager/non-nixos-home.nix ];
}
