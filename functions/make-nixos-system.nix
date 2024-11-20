{ allInputChannels, mkPkgs, linuxSystems, fullUserSet, hostname, nixBuildArgs }:
let
  allServicesSet = import ./all-services-set.nix { systemType = nixosSystemConfig.extraConfig.systemType; };
  nixosSystems = import ./nixos-systems.nix { inherit linuxSystems fullUserSet; };
  thisSystem = nixosSystems.systems."${hostname}";
  system = thisSystem.coreConfig.system;
  inputChannel = allInputChannels."${thisSystem.extraConfig.inputChannel or "default"}";
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

  # this is the core building block for **EVERY** NixOS System
  nixosSystemConfig = {
    coreConfig = {
      inherit (thisSystem.coreConfig) hostname ipv4Address primaryNetIface system;
      isNixOS = true;
      hostId = nixosSystems.commonConfig.hostIds."${hostname}";
      systemUser = thisSystem.systemUser or fullUserSet.pratham;
    };
    extraConfig = {
      gatewayAddr = thisSystem.gatewayAddr or nixosSystems.commonConfig.gatewayAddr;
      ipv4PrefixLength = thisSystem.ipv4PrefixLength or nixosSystems.commonConfig.ipv4PrefixLength;
      systemType = thisSystem.extraConfig.systemType or nixosSystems.commonConfig.systemTypes.server;
      inherit inputChannel allServicesSet nixBuildArgs;
    };
    kernelConfig = {
      inherit (nixosSystems.commonConfig) supportedFilesystemsSansZfs;
      useLongtermKernel = thisSystem.kernelConfig.useLongtermKernel or false;
      enableRustSupport = thisSystem.kernelConfig.enableRustSupport or false;
    };
  };
in nixosSystemConfig.extraConfig.inputChannel.nixpkgs.lib.nixosSystem {
  # nix eval .#nixosConfigurations."${nixosSystemConfig.coreConfig.hostname}"._module.specialArgs.nixosSystemConfig
  specialArgs = { inherit pkgsChannels nixosSystemConfig; };
  modules = [
    # root of the NixOS System configuration for a normal system
    ../nixos-configuration/systems/${hostname}
    ../nixos-configuration/modules
    ../nixos-configuration/modules/host-modules

    # third-party modules
    inputChannel.homeManager.nixosModules.default
    ../nixos-configuration/modules/home-manager/nixos-home.nix
  ];
}