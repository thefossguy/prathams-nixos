{
  allInputChannels,
  nixpkgsInputChannel,
  mkPkgs,
  linuxSystems,
  fullUserSet,
  system,
  nixBuildArgs,
  compressIso,
  guiSession,
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
    stableSmall = mkPkgs {
      inherit system;
      passedNixpkgs = allInputChannels.stableSmall.nixpkgs;
    };
    unstableSmall = mkPkgs {
      inherit system;
      passedNixpkgs = allInputChannels.unstableSmall.nixpkgs;
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
      dtbRelativePath = null;
      canAccessMyNixCache = true; # Safe to always assume the Nix is reachable
      inherit
        inputChannel
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
in

nixosSystemConfig.extraConfig.inputChannel.nixpkgs.lib.nixosSystem {
  # nix eval .#nixosConfigurations."${nixosSystemConfig.coreConfig.hostname}"._module.specialArgs.nixosSystemConfig
  specialArgs = { inherit pkgsChannels nixosSystemConfig; };
  modules = [
    # root of the NixOS System configuration for a normal system
    ../nixos-configuration/modules/iso
    ../nixos-configuration/modules
  ];
}
