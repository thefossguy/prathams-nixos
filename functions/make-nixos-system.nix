{
  allInputChannels,
  mkPkgs,
  linuxSystems,
  fullUserSet,
  hostname,
  nixBuildArgs,
}:
let
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
    stableSmall = mkPkgs {
      inherit system;
      passedNixpkgs = allInputChannels.stableSmall.nixpkgs;
    };
    unstableSmall = mkPkgs {
      inherit system;
      passedNixpkgs = allInputChannels.unstableSmall.nixpkgs;
    };
  };

  # this is the core building block for **EVERY** NixOS System
  nixosSystemConfig = {
    coreConfig = {
      inherit (thisSystem.coreConfig)
        hostname
        ipv4Address
        primaryNetIface
        system
        ;
      isNixOS = true;
      hostId = nixosSystems.commonConfig.hostIds."${hostname}";
      systemUser = thisSystem.coreConfig.systemUser or fullUserSet.pratham;
    };
    extraConfig = {
      gatewayAddr = thisSystem.extraConfig.gatewayAddr or nixosSystems.commonConfig.gatewayAddr;
      ipv4PrefixLength = thisSystem.extraConfig.ipv4PrefixLength or nixosSystems.commonConfig.ipv4PrefixLength;
      systemType = thisSystem.extraConfig.systemType or nixosSystems.commonConfig.systemTypes.server;
      dtbRelativePath = thisSystem.extraConfig.dtbRelativePath or null;
      canAccessMyNixCache = thisSystem.extraConfig.canAccessMyNixCache or true;
      allServicesSet = import ./all-services-set.nix {
        systemType = nixosSystemConfig.extraConfig.systemType;
        systemUserUsername = nixosSystemConfig.coreConfig.systemUser.username;
      };
      inherit inputChannel nixBuildArgs;
    };
    kernelConfig = {
      inherit (nixosSystems.commonConfig) supportedFilesystemsSansZfs;
      kernelVersion = thisSystem.kernelConfig.kernelVersion or "stable";
    };
  };
in
nixosSystemConfig.extraConfig.inputChannel.nixpkgs.lib.nixosSystem {
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
