{
  description = "Machines with Nix/NixOS";

  inputs = {
    nixpkgs-1stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager-1stable.url = "github:nix-community/home-manager/release-24.05";
    home-manager-1stable.inputs.nixpkgs.follows = "nixpkgs-1stable";

    nixpkgs-1stable-small.url = "github:NixOS/nixpkgs/nixos-24.05-small";
    home-manager-1stable-small.url = "github:nix-community/home-manager/release-24.05";
    home-manager-1stable-small.inputs.nixpkgs.follows = "nixpkgs-1stable-small";

    nixpkgs-0unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager-0unstable.url = "github:nix-community/home-manager/master";
    home-manager-0unstable.inputs.nixpkgs.follows = "nixpkgs-0unstable";

    nixpkgs-0unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    home-manager-0unstable-small.url = "github:nix-community/home-manager/master";
    home-manager-0unstable-small.inputs.nixpkgs.follows = "nixpkgs-0unstable-small";
  };

  outputs = { self,
    nixpkgs-1stable,         home-manager-1stable,
    nixpkgs-1stable-small,   home-manager-1stable-small,
    nixpkgs-0unstable,       home-manager-0unstable,
    nixpkgs-0unstable-small, home-manager-0unstable-small,
    ... }:
    let
      nixpkgsRelease = nixpkgs.lib.versions.majorMinor nixpkgs.lib.version;
      nixpkgs = nixpkgs-1stable;
      home-manager = home-manager-1stable;
      mkPkgs = { system, passedNixpkgs }: import passedNixpkgs { inherit system; };

      mkForEachSupportedSystem = supportedSystems: f: nixpkgs.lib.genAttrs supportedSystems (system: f rec {
        pkgs = pkgs1Stable;
        pkgs1Stable        = mkPkgs { inherit system; passedNixpkgs = nixpkgs-1stable; };
        pkgs1StableSmall   = mkPkgs { inherit system; passedNixpkgs = nixpkgs-1stable-small; };
        pkgs0Unstable      = mkPkgs { inherit system; passedNixpkgs = nixpkgs-0unstable; };
        pkgs0UnstableSmall = mkPkgs { inherit system; passedNixpkgs = nixpkgs-0unstable-small; };
      });

      linuxSystems = {
        aarch64 = "aarch64-linux";
        riscv64 = "riscv64-linux";
        x86_64 = "x86_64-linux";
      };

      darwinSystems = {
        aarch64 = "aarch64-darwin";
        x86_64 = "x86_64-darwin";
      };

      supportedLinuxSystems = nixpkgs.lib.attrValues linuxSystems;
      supportedSystems = supportedLinuxSystems ++ (nixpkgs.lib.attrValues darwinSystems);

      forEachSupportedLinuxSystem = mkForEachSupportedSystem supportedLinuxSystems;
      forEachSupportedSystem = mkForEachSupportedSystem supportedSystems;

      miscUsers = {
        # generate the `hashedPassword` using `mkpasswd`
        root.hashedPassword     = "$y$j9T$pu6FzqviKwK3OJFd/iRjc.$9AS4GXVkjYhrFKK/apJzQj3a8eTikI2S0jBhRAS/1e8";
        nixosIso.hashedPassword = "$y$j9T$Cvs/IpcrqGMijUQzTK/QT.$MUR/yeWILyoA8TK/lHGJmA32WR60OOko9WI/z7T0BB9";

        nixosIso = {
          username = "nixos";
          fullname = "nixos";
          enableLingering = true;
        };
      };

      # actual, real system users
      realUsers = {
        pratham = {
          username = "pratham";
          fullname = "Pratham Patel";
          hashedPassword = "$y$j9T$OfCucSHxqUwSKja6tw/K..$ookfkYGconxq6oqeRYMUR2WhjwFxiuDsIe9aCBQTVz8";
          enableLingering = true;
        };
      };

      systemUsers = miscUsers // realUsers;
      realUsersNames = nixpkgs.lib.concatStringsSep "' '" (nixpkgs.lib.attrNames realUsers);

      nixosMachines = {
        misc = {
          flakeUri = "/root/prathams-nixos";
          gatewayAddr = "10.0.0.1";
          ipv4PrefixLength = 24;

          # actual filesystems that I use
          supportedFilesystemsSansZFS = [
            "ext4"
            "vfat"
            "xfs"
          ];
        };

        hosts = {
          # generate the `hostId` using `head -c4 /dev/urandom | od -A none -t x4 | xargs`
          flameboi.hostId   = "20c95fe3";
          sentinel.hostId   = "041d6ae7";
          reddish.hostId    = "996ccb68";
          mahadev.hostId    = "c06c1a49";
          pawandev.hostId   = "2fefd3b2";
          stuti.hostId      = "07ca9dd4";
          chaturvyas.hostId = "6e52044b";
          vaaman.hostId     = "3c8077f9";
          vaayu.hostId      = "d81cd923";

          # "former" (now dead) "AI" "learning" PC (64GB; R9 3900XT; RTX 3070)
          flameboi = {
            hostname = "flameboi";
            ipv4Address = "10.0.0.13";
            networkingIface = "eth0";
            system = linuxSystems.x86_64;
          };

          # Raspberry Pi 4 Model B (4GB)
          sentinel = {
            hostname = "sentinel";
            ipv4Address = "10.0.0.14";
            networkingIface = "end0";
            system = linuxSystems.aarch64;
          };

          # Raspberry Pi 4 Model B (8GB)
          reddish = {
            hostname = "reddish";
            ipv4Address = "10.0.0.19";
            networkingIface = "end0";
            system = linuxSystems.aarch64;
          };

          # Radxa ROCK 5 Model B (16GB; RK3588)
          mahadev = {
            hostname = "mahadev";
            ipv4Address = "10.0.0.21";
            networkingIface = "enP4p65s0";
            system = linuxSystems.aarch64;
          };

          # Xunlong Orange Pi 5 (4GB; RK3588S)
          pawandev = {
            hostname = "pawandev";
            ipv4Address = "10.0.0.22";
            networkingIface = "eth0";
            system = linuxSystems.aarch64;
          };

          # FriendlyElec NanoPC-T6 (16GB; RK3588)
          stuti = {
            hostname = "stuti";
            ipv4Address = "10.0.0.23";
            networkingIface = "enP4p65s0"; # second one from the right
            system = linuxSystems.aarch64;
          };

          # FriendlyElec CM3588 NAS (16GB; RK3588)
          chaturvyas = {
            hostname = "chaturvyas";
            ipv4Address = "10.0.0.24";
            networkingIface = "enP4p65s0";
            forceLtsKernel = true;
            system = linuxSystems.aarch64;
          };

          # StarFive VisionFive 2 (8GB; JH7110)
          vaaman = {
            hostname = "vaaman";
            ipv4Address = "10.0.0.41";
            networkingIface = "end0"; # first one from the right
            system = linuxSystems.riscv64;
          };

          # StarFive VisionFive 2 (4GB; JH7110)
          vaayu = {
            hostname = "vaayu";
            ipv4Address = "10.0.0.42";
            networkingIface = "end0"; # first one from the right
            system = linuxSystems.riscv64;
          };
        };
      };

      nixosMachinesNames = nixpkgs.lib.concatStringsSep "' '" (nixpkgs.lib.attrNames nixosMachines.hosts);

      mkNixosSystem = hostname:
        let
          system = nixosMachines.hosts."${hostname}".system;
          pkgs1Stable        = mkPkgs { inherit system; passedNixpkgs = nixpkgs-1stable; };
          pkgs1StableSmall   = mkPkgs { inherit system; passedNixpkgs = nixpkgs-1stable-small; };
          pkgs0Unstable      = mkPkgs { inherit system; passedNixpkgs = nixpkgs-0unstable; };
          pkgs0UnstableSmall = mkPkgs { inherit system; passedNixpkgs = nixpkgs-0unstable-small; };
        in nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit pkgs1Stable pkgs1StableSmall pkgs0Unstable pkgs0UnstableSmall;

            inherit (nixosMachines.hosts."${hostname}") hostname ipv4Address networkingIface hostId;
            forceLtsKernel = nixosMachines.hosts."${hostname}".forceLtsKernel or false;
            systemUser = nixosMachines.hosts."${hostname}".systemUser or systemUsers.pratham;
          };

          modules = [
            ./nixos-configuration/hosts/${hostname}/default.nix
            ./nixos-configuration/hosts/hosts-common.nix
            self.nixosModules.customNixosBaseModule
            home-manager.nixosModules.home-manager {
              home-manager.extraSpecialArgs = { inherit pkgs1Stable pkgs1StableSmall pkgs0Unstable pkgs0UnstableSmall; };
            }
          ] ++ (nixosMachines.hosts."${hostname}".extraSystemModules or [ ]);
        };

      mkNonNixosHomeManager = pkgs: systemUser:
        let
          system = pkgs.stdenv.system;
        in home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit systemUser nixpkgsRelease;
            pkgs1Stable        = mkPkgs { inherit system; passedNixpkgs = nixpkgs-1stable; };
            pkgs1StableSmall   = mkPkgs { inherit system; passedNixpkgs = nixpkgs-1stable-small; };
            pkgs0Unstable      = mkPkgs { inherit system; passedNixpkgs = nixpkgs-0unstable; };
            pkgs0UnstableSmall = mkPkgs { inherit system; passedNixpkgs = nixpkgs-0unstable-small; };
          };
          modules = [ ./nixos-configuration/home-manager/non-nixos-home.nix ];
        };

      mkNixosIso = systemArch:
        nixpkgs-1stable-small.lib.nixosSystem {
          system = linuxSystems."${systemArch}";
          modules = [ self.nixosModules.customNixosIsoModule ];
        };
    in {
      nixosModules = {
        customNixosBaseModule = {
          _module.args = {
            inherit home-manager nixpkgsRelease;
            inherit (nixosMachines.misc) flakeUri gatewayAddr ipv4PrefixLength supportedFilesystemsSansZFS;
          };

          imports = let
            nixpkgsChannelPath = "nixpkgs/channels/nixpkgs";
          in [
            home-manager.nixosModules.home-manager { imports = [ ./nixos-configuration/home-manager/nixos-home.nix ]; }
            ./nixos-configuration/configuration.nix

            {
              # declare config options that depend on "super sets"
              # which are best not passed to the nixos-configuration/* files
              environment.etc."${nixpkgsChannelPath}".source = nixpkgs.outPath;
              nix.registry.nixpkgs.flake = nixpkgs;
              nix.nixPath = [
                "nixpkgs=/etc/${nixpkgsChannelPath}"
                "nixos-config=/etc/nixos/configuration.nix"
                "/nix/var/nix/profiles/per-user/root/channels"
              ];
              users.users.root.hashedPassword = "${systemUsers.root.hashedPassword}";
            }
          ];
        };

        customNixosIsoModule = {
          _module.args = { inherit (nixosMachines.misc) supportedFilesystemsSansZFS; };
          imports = [ ./nixos-configuration/_iso/iso.nix ];
        };
      };

      nixosConfigurations = {
        flameboi   = mkNixosSystem "flameboi";
        sentinel   = mkNixosSystem "sentinel";
        reddish    = mkNixosSystem "reddish";
        mahadev    = mkNixosSystem "mahadev";
        pawandev   = mkNixosSystem "pawandev";
        stuti      = mkNixosSystem "stuti";
        chaturvyas = mkNixosSystem "chaturvyas";
        vaaman     = mkNixosSystem "vaaman";
        vaayu      = mkNixosSystem "vaayu";

        z-iso-aarch64 = mkNixosIso "aarch64";
        z-iso-x86_64  = mkNixosIso "x86_64";
        z-iso-riscv64 = mkNixosIso "riscv64";
      };

      legacyPackages = forEachSupportedSystem ({ pkgs, ... }: {
        homeConfigurations."${systemUsers.pratham.username}" = mkNonNixosHomeManager pkgs systemUsers.pratham;
      });

      packages = forEachSupportedSystem ({ pkgs, ... }: {
        listOfNixosMachines = pkgs.writeTextFile {
          name = "all-nixos-machines.sh";
          text = "all_nixos_machines=('${nixosMachinesNames}')";
        };
        listOfRealUsers = pkgs.writeTextFile {
          name = "all-users.sh";
          text = "all_users=('${realUsersNames}')";
        };
        listOfRealPackages = pkgs.writeTextFile {
          name = "all-packages.sh";
          text = let
            allRealPackages = pkgs.lib.lists.partition
              (pkg: (pkg == "listOfRealPackages") || (pkg == "listOfRealUsers") || (pkg == "listOfNixosMachines"))
              (pkgs.lib.attrNames self.packages.${pkgs.stdenv.system});
            allRealPackagesNames = pkgs.lib.concatStringsSep "' '" allRealPackages.wrong;
          in
            "all_packages=('${allRealPackagesNames}')";
        };
      });

      devShells = forEachSupportedSystem ({ pkgs, ... }: {
        default = pkgs.mkShell {
          packages = with pkgs; [ just nixfmt-classic ];

          env = {
            UPDATE_LOCKFILE = 0;
            USE_NOM_INSTEAD = 1;
            DO_DRY_RUN = 1;
          };
        };
      });
    };
}
