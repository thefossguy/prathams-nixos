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

    nix-serve-ng.url = "github:aristanetworks/nix-serve-ng";
  };

  outputs = { self,
    nixpkgs-1stable,         home-manager-1stable,
    nixpkgs-1stable-small,   home-manager-1stable-small,
    nixpkgs-0unstable,       home-manager-0unstable,
    nixpkgs-0unstable-small, home-manager-0unstable-small,
    nix-serve-ng,
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
        root.hashedPassword     = "$y$j9T$BzG/Oq8bbL.2uq2/MuRox.$cofHV3CnpcdI4PI5nEEJz//nWqFWiAL8Mfj8/adLJhC";
        nixosIso.hashedPassword = "$y$j9T$vMupXoz6rvpT55CkuDenZ0$umu0dpi6NG7lllLcoP9L.wY0ZxEY2wbmPwkiBFsejnC";
        nixosIso.username = "nixos";
      };

      # actual, real system users (`"${user}IsInRealUsers"` is `true`)
      # i.e. the ones that represent a human associated to it
      # not for users created for running systemd services or any other task
      realUsers = {
        pratham = {
          username = "pratham";
          fullname = "Pratham Patel";
          hashedPassword = "$y$j9T$dyQH1g6q6YjT.8lNruhJT.$xU2x3Phl3L6ey6tIWfmBlgHlCMrTnAxn9yD.a2/yS82";
          enableLingering = true;
          prathamIsInRealUsers = true;
        };
      };

      systemUsers = miscUsers // realUsers;

      nixosMachines = {
        misc = {
          gatewayAddr = "10.0.0.1";
          ipv4PrefixLength = 24;
          latestLtsKernel = "linuxPackages_6_6"; # so that we can haz a newer LTS kernel after the yy.11 release
          latestStableKernel = "linuxPackages_latest";

          machineTypes = {
            desktop = "Desktop";
            laptop  = "Laptop";
            server  = "Server";
          };

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
            machineType = nixosMachines.misc.machineTypes.desktop;
            system = linuxSystems.x86_64;
          };

          # Lenovo Yoga Slim 6 (Intel 16GB; i5-13500H; Iris Xe)
          indra = {
            hostname = "indra";
            ipv4Address = "10.0.0.50";
            networkingIface = "wlp0s20f3";
            machineType = nixosMachines.misc.machineTypes.laptop;
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
            hostname = "raajan";
            ipv4Address = "10.0.0.59";
            networkingIface = "end0";
            system = linuxSystems.aarch64;
          };

          # Radxa ROCK 5 Model B (16GB; RK3588)
          mahadev = {
            hostname = "mahadev";
            ipv4Address = "10.0.0.21";
            networkingIface = "enP4p65s0";
            forceLtsKernel = true;
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

          # virtual machine
          zVirtSys = let threeOctets = ""; in {
            hostId = "FFFFFFFF";
            hostname = "zVirtSys";
            gatewayAddr = "${threeOctets}.1";
            ipv4Address = "${threeOctets}.";
            ipv4PrefixLength = -1;
            networkingIface = "";
            forceLtsKernel = false;
            system = null;
          };
        };
      };

      mkNixosSystem = { hostname, passed-nixpkgs ? nixpkgs, passed-home-manager ? home-manager }:
        let
          nixpkgs = passed-nixpkgs;
          home-manager = passed-home-manager;

          system = nixosMachines.hosts."${hostname}".system;
          machineType = nixosMachines.hosts."${hostname}".machineType or nixosMachines.misc.machineTypes.server;
          pkgs1Stable        = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-1stable; };
          pkgs1StableSmall   = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-1stable-small; };
          pkgs0Unstable      = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-0unstable; };
          pkgs0UnstableSmall = mkPkgs { inherit system; passed-nixpkgs = nixpkgs-0unstable-small; };
        in nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system;
            inherit (nixosMachines.misc) latestLtsKernel latestStableKernel;
            inherit pkgs1Stable pkgs1StableSmall pkgs0Unstable pkgs0UnstableSmall;

            inherit (nixosMachines.hosts."${hostname}") hostname ipv4Address networkingIface hostId;
            forceLtsKernel = nixosMachines.hosts."${hostname}".forceLtsKernel or false;
            systemUser = nixosMachines.hosts."${hostname}".systemUser or systemUsers.pratham;
            gatewayAddr = nixosMachines.hosts."${hostname}".gatewayAddr or nixosMachines.misc.gatewayAddr;
            ipv4PrefixLength = nixosMachines.hosts."${hostname}".ipv4PrefixLength or nixosMachines.misc.ipv4PrefixLength;
          };

          modules = [
            ./nixos-configuration/hosts/${hostname}/default.nix
            ./nixos-configuration/hosts/hosts-common.nix
            (self.nixosModules.customNixosBaseModule { inherit passed-nixpkgs passed-home-manager; })
            home-manager.nixosModules.home-manager { home-manager.extraSpecialArgs = { inherit pkgs1Stable pkgs1StableSmall pkgs0Unstable pkgs0UnstableSmall; }; }
            {
              # this is an ugly hack that will probably stay for an eternity lol
              config.custom-options."isNixos${machineType}" = true;
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

      mkNixosIso = { systemArch, enableZfs ? false }:
        nixpkgs-1stable-small.lib.nixosSystem {
          system = linuxSystems."${systemArch}";
          specialArgs = {
            inherit enableZfs;
            inherit (nixosMachines.misc) latestLtsKernel latestStableKernel;
          };
          modules = [ self.nixosModules.customNixosIsoModule ];
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
            inherit (nixosMachines.misc) supportedFilesystemsSansZFS;
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

            nix-serve-ng.nixosModules.default
            home-manager.nixosModules.home-manager { imports = [ ./nixos-configuration/home-manager/nixos-home.nix ]; }
          ];
        };

        customNixosIsoModule = {
          _module.args = {
            inherit (nixosMachines.misc) supportedFilesystemsSansZFS;
            isoUser = miscUsers.nixosIso;
          };
          imports = [ ./nixos-configuration/_iso/iso.nix ];
        };
      };

      nixosConfigurations = {
        flameboi   = mkNixosSystem { hostname = "flameboi"; passed-nixpkgs = nixpkgs-1stable; passed-home-manager = home-manager-1stable; };
        indra      = mkNixosSystem { hostname = "indra";    passed-nixpkgs = nixpkgs-1stable; passed-home-manager = home-manager-1stable; };
        sentinel   = mkNixosSystem { hostname = "sentinel"; passed-nixpkgs = nixpkgs-0unstable-small; passed-home-manager = home-manager-0unstable-small; };
        reddish    = mkNixosSystem { hostname = "reddish"; };
        raajan     = mkNixosSystem { hostname = "raajan"; };
        mahadev    = mkNixosSystem { hostname = "mahadev"; };
        pawandev   = mkNixosSystem { hostname = "pawandev"; };
        stuti      = mkNixosSystem { hostname = "stuti"; };
        chaturvyas = mkNixosSystem { hostname = "chaturvyas"; };
        vaaman     = mkNixosSystem { hostname = "vaaman"; };
        vaayu      = mkNixosSystem { hostname = "vaayu"; };

        z-iso-nozfs-aarch64 = mkNixosIso { systemArch = "aarch64"; };
        z-iso-nozfs-riscv64 = mkNixosIso { systemArch = "riscv64"; };
        z-iso-nozfs-x86_64  = mkNixosIso { systemArch = "x86_64"; };
        z-iso-zfs-aarch64   = mkNixosIso { systemArch = "aarch64"; enableZfs = true; };
        z-iso-zfs-riscv64   = mkNixosIso { systemArch = "riscv64"; enableZfs = true; };
        z-iso-zfs-x86_64    = mkNixosIso { systemArch = "x86_64";  enableZfs = true; };

        zVirtSys = mkNixosSystem { hostname = "zVirtSys"; passed-nixpkgs = nixpkgs-0unstable-small; passed-home-manager = home-manager-0unstable-small; };
      };

      legacyPackages = forEachSupportedSystem ({ pkgs, ... }: {
        homeConfigurations."${systemUsers.pratham.username}" = mkNonNixosHomeManager pkgs systemUsers.pratham;
      });

      packages = forEachSupportedSystem ({ pkgs, ... }: {
      });

      devShells = forEachSupportedSystem ({ pkgs, ... }: {
        default = pkgs.mkShellNoCC {
          packages = pkgs.callPackage ./nixos-configuration/_iso/packages-in-iso.nix {};
          shellHook = ''
          if ! nix help 1>/dev/null 2>&1; then
              export nix='nix --extra-experimental-features nix-command --extra-experimental-features flakes'
              alias nix="''${nix}"
          fi
          '';
        };
      });

      apps = forEachSupportedSystem ({ pkgs, ... }: let
        lib = pkgs.lib;
        system = pkgs.stdenv.system;
        nixBuildFlags = "--verbose --trace-verbose --print-build-logs --show-trace";
        nomBuildCmd = "${pkgs.nix-output-monitor}/bin/nom build";
        nixBuildCmd = "${pkgs.nix}/bin/nix build";
        nixOrNom = ''
          if [[ "$(id -u)" -eq 0 ]]; then
              nixBuildCmd='${nixBuildCmd} ${nixBuildFlags} --max-jobs 1'
          else
              nixBuildCmd='${nomBuildCmd} ${nixBuildFlags}'
          fi
        '';

        buildableSystems = lib.filterAttrs (name: host: host.system == system) nixosMachines.hosts;
        allPackages = pkgs.lib.attrNames self.packages.${pkgs.stdenv.system};

        listOfAllSystems  = lib.attrNames buildableSystems;
        listOfAllUsers    = lib.attrNames realUsers;
        listOfAllPackages = allPackages;

        buildNixBuildExpressions = { prefix, infixes, suffix }:
          lib.concatStringsSep " " (
            map (infix: ".#${prefix}." + builtins.toString infix + ".${suffix}") infixes
          );
        buildExpressionOfSystem = nixosSystems:  buildNixBuildExpressions {
          prefix  = "nixosConfigurations";
          infixes = nixosSystems;
          suffix  = "config.system.build.toplevel";
        };
        buildExpressionOfHome = users: buildNixBuildExpressions {
          prefix  = "legacyPackages.${system}.homeConfigurations";
          infixes = users;
          suffix  = "activationPackage";
        };
        buildExpressionOfPackage = packages: buildNixBuildExpressions {
          prefix  = "packages.${system}";
          infixes = packages;
          suffix  = "";
        };
        buildExpressionOfZfsIso   = ".#nixosConfigurations.z-iso-zfs-$(uname -m).config.system.build.isoImage";
        buildExpressionOfNozfsIso = ".#nixosConfigurations.z-iso-nozfs-$(uname -m).config.system.build.isoImage";

      in {
        continuousBuild = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "nix-run-continuous-build" ''
            ${nixOrNom}
            set -x
            ''${nixBuildCmd} ${buildExpressionOfPackage listOfAllPackages} ${buildExpressionOfHome listOfAllUsers} ${buildExpressionOfSystem listOfAllSystems}
          ''}/bin/nix-run-continuous-build";
        };
        buildEverything = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "nix-run-build-everything" ''
            ${nixOrNom}
            set -x
            ''${nixBuildCmd} ${buildExpressionOfPackage listOfAllPackages} ${buildExpressionOfHome listOfAllUsers} ${buildExpressionOfSystem listOfAllSystems} ${buildExpressionOfZfsIso} ${buildExpressionOfNozfsIso}
          ''}/bin/nix-run-build-everything";
        };

        buildThisNixosSystem = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "nix-run-build-this-nixos-system" ''
            ${nixOrNom}
            set -x
            ''${nixBuildCmd} ${buildExpressionOfSystem ["\${NIXOS_MACHINE_HOSTNAME:-}"]}
          ''}/bin/nix-run-build-this-nixos-system";
        };
        buildAllNixosSystems = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "nix-runall-nixos-systems" ''
            ${nixOrNom}
            set -x
            ''${nixBuildCmd} ${buildExpressionOfSystem listOfAllSystems}
          ''}/bin/nix-runall-nixos-systems";
        };

        buildThisHome = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "nix-run-build-this-home" ''
            ${nixOrNom}
            set -x
            ''${nixBuildCmd} ${buildExpressionOfHome ["\${USER:-}"]}
          ''}/bin/nix-run-build-this-home";
        };
        buildAllHomes = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "nix-run-build-all-homes" ''
            ${nixOrNom}
            set -x
            ''${nixBuildCmd} ${buildExpressionOfHome listOfAllUsers}
          ''}/bin/nix-run-build-all-homes";
        };

        buildAllPackages = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "nix-run-build-all-packages" ''
            ${nixOrNom}
            set -x
            ''${nixBuildCmd} ${buildExpressionOfPackage listOfAllPackages}
          ''}/bin/nix-run-build-all-packages";
        };

        buildZfsIso = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "nix-run-build-zfs-iso" ''
            ${nixOrNom}
            set -x
            ''${nixBuildCmd} ${buildExpressionOfZfsIso}
          ''}/bin/nix-run-build-zfs-iso";
        };
        buildNozfsIso = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "nix-run-build-nozfs-iso" ''
            ${nixOrNom}
            set -x
            ''${nixBuildCmd} ${buildExpressionOfNozfsIso}
          ''}/bin/nix-run-build-nozfs-iso";
        };
        buildAllIsos = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "nix-run-build-all-isos" ''
            ${nixOrNom}
            set -x
            ''${nixBuildCmd} ${buildExpressionOfZfsIso} ${buildExpressionOfNozfsIso}
          ''}/bin/nix-run-build-all-isos";
        };
      });
    };
}
