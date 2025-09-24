{
  nixpkgs,
  nixpkgs-stable,
  linuxSystems,
  fullUserSet,
  system,
  nixBuildArgs,
  compressIso,
  guiSession,
}:

let
  nixosSystems = import ./nixos-systems.nix { inherit linuxSystems fullUserSet; };
  nixosSystemConfig = {
    coreConfig = {
      inherit system;
      isNixOS = true;
      systemUser = fullUserSet.iso;
    };
    extraConfig = {
      systemType = nixosSystems.commonConfig.systemTypes.server;
      dtbRelativePath = null;
      canAccessMyNixCache = true; # Safe to always assume the Nix is reachable
      inherit
        nixpkgs
        nixBuildArgs
        compressIso
        guiSession
        ;
    };
    kernelConfig = {
      inherit (nixosSystems.commonConfig) supportedFilesystemsSansZfs;
      tree = "stable";
    };
  };
  stablePkgs = nixpkgs-stable.legacyPackages.${system};
in

nixpkgs.lib.nixosSystem {
  # nix eval .#nixosConfigurations."${nixosSystemConfig.coreConfig.hostname}"._module.specialArgs.nixosSystemConfig
  specialArgs = { inherit stablePkgs nixosSystemConfig; };
  modules = [
    # root of the NixOS System configuration for a normal system
    ../nixos-configuration/modules/iso
    ../nixos-configuration/modules
  ];
}
