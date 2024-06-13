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
      nixpkgs = nixpkgs-1stable-small;
      home-manager = home-manager-1stable-small;
      mkPkgs = { system, passed-nixpkgs }: import passed-nixpkgs { inherit system; };

      mkForEachSupportedSystem = supportedSystems: f:
        nixpkgs.lib.genAttrs supportedSystems (system:
          f rec {
            pkgs = pkgs1Stable;
            pkgs1Stable        = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-1stable; };
            pkgs1StableSmall   = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-1stable-small; };
            pkgs0Unstable      = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-0unstable; };
            pkgs0UnstableSmall = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-0unstable-small; };
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

      nixosMachines = {
        misc = {
          flakeUri = "/etc/nixos";
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
          indra.hostId      = "d92f6246";
          sentinel.hostId   = "041d6ae7";
          reddish.hostId    = "996ccb68";
          mahadev.hostId    = "c06c1a49";
          pawandev.hostId   = "2fefd3b2";
          stuti.hostId      = "07ca9dd4";
          chaturvyas.hostId = "6e52044b";
          raajan.hostId     = "337088b4";
          vaaman.hostId     = "3c8077f9";
          vaayu.hostId      = "d81cd923";

          # "former" (now dead) "AI" "learning" PC (64GB; R9 3900XT; RTX 3070)
          flameboi = {
            hostname = "flameboi";
            ipv4Address = "10.0.0.13";
            networkingIface = "eth0";
            system = linuxSystems.x86_64;
          };

          # Lenovo Yoga Slim 6 (Intel 16GB; i5-13500H; Iris Xe)
          indra = {
            hostname = "indra";
            ipv4Address = "10.0.0.50";
            networkingIface = "wlp0s20f3";
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

          # Raspberry Pi 5 Model B (8GB)
          raajan = {
            hostname = "reddish";
            ipv4Address = "10.0.0.59";
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

      mkNixosSystem = { hostname, passed-nixpkgs ? nixpkgs, passed-home-manager ? home-manager }:
        let
          nixpkgs = passed-nixpkgs;
          home-manager = passed-home-manager;

          system = nixosMachines.hosts."${hostname}".system;
          pkgs1Stable        = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-1stable; };
          pkgs1StableSmall   = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-1stable-small; };
          pkgs0Unstable      = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-0unstable; };
          pkgs0UnstableSmall = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-0unstable-small; };
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
            (self.nixosModules.customNixosBaseModule { inherit passed-nixpkgs passed-home-manager; })
            home-manager.nixosModules.home-manager {
              home-manager.extraSpecialArgs = { inherit pkgs1Stable pkgs1StableSmall pkgs0Unstable pkgs0UnstableSmall; };
            }
          ] ++ (nixosMachines.hosts."${hostname}".extraSystemModules or [ ]);
        };

      mkNonNixosHomeManager = pkgs: systemUser:
        let system = pkgs.stdenv.system;
        in home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit systemUser;
            pkgs1Stable        = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-1stable; };
            pkgs1StableSmall   = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-1stable-small; };
            pkgs0Unstable      = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-0unstable; };
            pkgs0UnstableSmall = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-0unstable-small; };
          };
          modules = [ ./nixos-configuration/home-manager/non-nixos-home.nix ];
        };

      mkNixosIso = { systemArch, isoModuleName ? "installation-cd-minimal.nix" }: let
        nixpkgs = nixpkgs-1stable-small;
        in nixpkgs.lib.nixosSystem {
          system = linuxSystems."${systemArch}";
          modules = [
            self.nixosModules.customNixosIsoModule
            { imports = [ "${nixpkgs.outPath}/nixos/modules/installer/cd-dvd/${isoModuleName}" ]; }
          ];
        };
    in {
      nixosModules = {
        customNixosBaseModule = { passed-nixpkgs ? nixpkgs, passed-home-manager ? home-manager, ... }:
        let
          nixpkgs = passed-nixpkgs;
          home-manager = passed-home-manager;
        in {
          _module.args = {
            inherit home-manager nixpkgs;
            inherit (nixosMachines.misc) flakeUri gatewayAddr ipv4PrefixLength supportedFilesystemsSansZFS;
          };

          imports = let nixpkgsChannelPath = "nixpkgs/channels/nixpkgs";
          in [
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

            home-manager.nixosModules.home-manager { imports = [ ./nixos-configuration/home-manager/nixos-home.nix ]; }
          ];
        };

        customNixosIsoModule = {
          _module.args = { inherit (nixosMachines.misc) supportedFilesystemsSansZFS; };
          imports = [ ./nixos-configuration/_iso/iso.nix ];
        };
      };

      nixosConfigurations = {
        flameboi   = mkNixosSystem { hostname = "flameboi"; passed-nixpkgs = nixpkgs-1stable; passed-home-manager = home-manager-1stable; };
        indra      = mkNixosSystem { hostname = "indra";    passed-nixpkgs = nixpkgs-1stable; passed-home-manager = home-manager-1stable; };
        sentinel   = mkNixosSystem { hostname = "sentinel"; };
        reddish    = mkNixosSystem { hostname = "reddish"; };
        raajan     = mkNixosSystem { hostname = "raajan"; };
        mahadev    = mkNixosSystem { hostname = "mahadev"; };
        pawandev   = mkNixosSystem { hostname = "pawandev"; };
        stuti      = mkNixosSystem { hostname = "stuti"; };
        chaturvyas = mkNixosSystem { hostname = "chaturvyas"; };
        vaaman     = mkNixosSystem { hostname = "vaaman"; };
        vaayu      = mkNixosSystem { hostname = "vaayu"; };

        z-iso-aarch64 = mkNixosIso { systemArch = "aarch64"; };
        z-iso-riscv64 = mkNixosIso { systemArch = "riscv64"; };
        z-iso-x86_64  = mkNixosIso { systemArch = "x86_64"; };
        z-iso-aarch64-kde = mkNixosIso { systemArch = "aarch64"; isoModuleName = "installation-cd-graphical-calamares-plasma6.nix"; };
        z-iso-riscv64-kde = mkNixosIso { systemArch = "riscv64"; isoModuleName = "installation-cd-graphical-calamares-plasma6.nix"; };
        z-iso-x86_64-kde  = mkNixosIso { systemArch = "x86_64";  isoModuleName = "installation-cd-graphical-calamares-plasma6.nix"; };
      };

      legacyPackages = forEachSupportedSystem ({ pkgs, ... }: {
        homeConfigurations."${systemUsers.pratham.username}" = mkNonNixosHomeManager pkgs systemUsers.pratham;
      });

      packages = forEachSupportedSystem ({ pkgs, ... }: {
      });

      apps = forEachSupportedSystem ({ pkgs, ... }: {
        buildThisNixosSystem = {
          type = "app";
          program = "${self.builders.${pkgs.stdenv.system}.thisNixosSystem}/bin/run.sh";
        };
        buildAllNixosSystems = {
          type = "app";
          program = "${self.builders.${pkgs.stdenv.system}.allNixosSystems}/bin/run.sh";
        };

        buildThisHome = {
          type = "app";
          program = "${self.builders.${pkgs.stdenv.system}.thisHome}/bin/run.sh";
        };
        buildAllHomes = {
          type = "app";
          program = "${self.builders.${pkgs.stdenv.system}.allHomes}/bin/run.sh";
        };

        buildThisPackage = {
          type = "app";
          program = "${self.builders.${pkgs.stdenv.system}.thisPackage}/bin/run.sh";
        };
        buildAllPackages = {
          type = "app";
          program = "${self.builders.${pkgs.stdenv.system}.allPackages}/bin/run.sh";
        };

        buildIsos = {
          type = "app";
          program = "${self.builders.${pkgs.stdenv.system}.allIsos}/bin/run.sh";
        };
        buildEverything = {
          type = "app";
          program = "${self.builders.${pkgs.stdenv.system}.default}/bin/run.sh";
        };
      });

      builders = forEachSupportedSystem ({ pkgs, ... }: let
        lib = pkgs.lib;
        system = pkgs.stdenv.system;
        nixBuilder = "${pkgs.nix-output-monitor}/bin/nom";

        buildableSystems = lib.filterAttrs (name: host: host.system == system) nixosMachines.hosts;
        allPackages = pkgs.lib.attrNames self.packages.${pkgs.stdenv.system};

        concatListToString = passedList: lib.concatStringsSep "," passedList;
        encloseInBrackets = passedList: if (lib.lists.length passedList > 1)
          then "{" + concatListToString passedList + "}"
          else concatListToString passedList;

        listOfAllSystems = encloseInBrackets (lib.attrNames buildableSystems);
        listOfAllUsers = encloseInBrackets (lib.attrNames realUsers);
        listOfAllPackages = encloseInBrackets allPackages;

        buildExpressionOfSystem  = nixosSystem: if (lib.stringLength nixosSystem == 0) then ""
          else ".#nixosConfigurations.${nixosSystem}.config.system.build.toplevel";
        buildExpressionOfHome    = user:        if (lib.stringLength user == 0) then ""
          else ".#legacyPackages.${system}.homeConfigurations.${user}.activationPackage";
        buildExpressionOfPackage = package:     if (lib.stringLength package== 0) then ""
          else ".#packages.${system}.${package}";
        buildExpressionOfIso     = ".#nixosConfigurations.z-iso-$(uname -m){,-kde}.config.system.build.isoImage";
      in {
        default = pkgs.writeShellScriptBin "run.sh" ''
          set -x
          # the order matters because they are listed in the priority of build status to me
          ${nixBuilder} build  ${buildExpressionOfSystem "${listOfAllSystems}"} ${buildExpressionOfHome "${listOfAllUsers}"} ${buildExpressionOfPackage "${listOfAllPackages}"} ${buildExpressionOfIso}
        '';

        thisNixosSystem = pkgs.writeShellScriptBin "run.sh" ''
          set -x
          ${nixBuilder} build ${buildExpressionOfSystem ''''${NIXOS_MACHINE_HOSTNAME:-}''}
        '';
        allNixosSystems = pkgs.writeShellScriptBin "run.sh" ''
          set -x
          ${nixBuilder} build ${buildExpressionOfSystem "${listOfAllSystems}"}
        '';

        thisHome = pkgs.writeShellScriptBin "run.sh" ''
          set -x
          ${nixBuilder} build ${buildExpressionOfHome ''''${USER:-}''}
        '';
        allHomes = pkgs.writeShellScriptBin "run.sh" ''
          set -x
          ${nixBuilder} build ${buildExpressionOfHome "${listOfAllUsers}"}
        '';

        thisPackage = pkgs.writeShellScriptBin "run.sh" ''
          set -x
          ${nixBuilder} build ${buildExpressionOfPackage ''''${1:-}''}
        '';
        allPackages = pkgs.writeShellScriptBin "run.sh" ''
          set -x
          ${nixBuilder} build ${buildExpressionOfPackage "${listOfAllPackages}"}
        '';

        allIso = pkgs.writeShellScriptBin "run.sh" ''
          set -x
          ${nixBuilder} build ${buildExpressionOfIso}
        '';
      });

      devShells = forEachSupportedSystem ({ pkgs, ... }: {
        default = pkgs.mkShell {
          packages = with pkgs; [ nixfmt-classic ];

          env = {
            UPDATE_LOCKFILE = 0;
            USE_NOM_INSTEAD = 1;
            DO_DRY_RUN = 1;
          };
        };
      });
    };
}
