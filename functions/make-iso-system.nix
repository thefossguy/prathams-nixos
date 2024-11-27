{
  allInputChannels,
  nixpkgsInputChannel,
  mkPkgs,
  linuxSystems,
  fullUserSet,
  system,
  nixBuildArgs,
  useLongtermKernel,
  enableRustSupport,
}:

let
  pkgsChannels = {
    stable = mkPkgs {
      inherit system;
      passedNixpkgs = allInputChannels.stable.nixpkgs;
    };
    unstable = mkPkgs {
      inherit system;
      passedNixpkgs = allInputChannels.unstable.nixpkgs;
    };
  };

  nixosSystems = import ./nixos-systems.nix { inherit linuxSystems fullUserSet; };
  inputChannel = allInputChannels."${nixpkgsInputChannel}";
  # this is the core building block for **EVERY** NixOS System
  nixosSystemConfig = {
    coreConfig = {
      inherit system;
      isNixOS = true;
      systemUser = fullUserSet.iso;
    };
    extraConfig = {
      systemType = nixosSystems.commonConfig.systemTypes.server;
      inherit inputChannel nixBuildArgs;
    };
    kernelConfig = {
      inherit (nixosSystems.commonConfig) supportedFilesystemsSansZfs;
      inherit useLongtermKernel enableRustSupport;
    };
  };
in

nixosSystemConfig.extraConfig.inputChannel.nixpkgs.lib.nixosSystem {
  # nix eval .#nixosConfigurations."${nixosSystemConfig.coreConfig.hostname}"._module.specialArgs.nixosSystemConfig
  specialArgs = { inherit pkgsChannels nixosSystemConfig; };
  modules = [
    # root of the NixOS System configuration for a normal system
    ../nixos-configuration/modules/iso
    ../nixos-configuration/modules

    inputChannel.homeManager.nixosModules.default
  ];
}
