{
  nixpkgs,
  home-manager,
  nixpkgs-stable,
  linuxSystems,
  fullUserSet,
  hostname,
  nixBuildArgs,
}:
let
  nixosSystems = import ./nixos-systems.nix { inherit linuxSystems; };
  thisSystem = nixosSystems.systems."${hostname}";
  stablePkgs = nixpkgs-stable.legacyPackages.${thisSystem.coreConfig.system};

  # this is the core building block for **EVERY** NixOS System
  nixosSystemConfig = {
    coreConfig = {
      inherit (thisSystem.coreConfig)
        hostname
        ipv4Address
        primaryNetIface
        addrMAC
        system
        ;
      isNixOS = true;
      hostId = nixosSystems.commonConfig.hostIds."${hostname}";
      systemUser = thisSystem.coreConfig.systemUser or fullUserSet.pratham;
    };
    extraConfig = {
      gatewayAddr = thisSystem.extraConfig.gatewayAddr or nixosSystems.commonConfig.gatewayAddr;
      useDHCP = thisSystem.extraConfig.useDHCP or false;
      ipv4PrefixLength = thisSystem.extraConfig.ipv4PrefixLength or nixosSystems.commonConfig.ipv4PrefixLength;
      systemType = thisSystem.extraConfig.systemType or nixosSystems.commonConfig.systemTypes.server;
      dtbRelativePath = thisSystem.extraConfig.dtbRelativePath or null;
      canAccessMyNixCache = thisSystem.extraConfig.canAccessMyNixCache or true;
      allServicesSet = import ./all-services-set.nix {
        systemType = nixosSystemConfig.extraConfig.systemType;
        systemUserUsername = nixosSystemConfig.coreConfig.systemUser.username;
      };
      inherit nixpkgs nixBuildArgs;
    };
    kernelConfig = {
      inherit (nixosSystems.commonConfig) supportedFilesystemsSansZfs;
      tree = thisSystem.kernelConfig.tree or "stable";
    };
  };
in
nixpkgs.lib.nixosSystem {
  # nix eval .#nixosConfigurations."${nixosSystemConfig.coreConfig.hostname}"._module.specialArgs.nixosSystemConfig
  specialArgs = { inherit stablePkgs nixosSystemConfig; };
  modules = [
    # root of the NixOS System configuration for a normal system
    ../nixos-configuration/systems/${hostname}
    ../nixos-configuration/modules
    ../nixos-configuration/modules/host-modules

    # third-party modules
    home-manager.nixosModules.default
    ../nixos-configuration/modules/home-manager/nixos-home.nix
  ];
}
