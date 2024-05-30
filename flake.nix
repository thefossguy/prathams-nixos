{
  description = "Machines with Nix/NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      nixpkgsRelease = "23.11";

      mkForEachSupportedSystem = supportedSystems: f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

      linuxSystems = {
        aarch64 = "aarch64-linux";
        x86_64 = "x86_64-linux";
        riscv64 = "riscv64-linux";
      };

      darwinSystems = {
        aarch64 = "aarch64-darwin";
        x86_64 = "x86_64-darwin";
      };

      supportedLinuxSystems = nixpkgs.lib.attrValues linuxSystems;
      supportedDarwinSystems = nixpkgs.lib.attrValues darwinSystems;
      supportedSystems = supportedLinuxSystems ++ supportedDarwinSystems;

      forEachSupportedLinuxSystem = mkForEachSupportedSystem supportedLinuxSystems;
      forEachSupportedDarwinSystem = mkForEachSupportedSystem supportedDarwinSystems;
      forEachSupportedSystem = mkForEachSupportedSystem supportedSystems;

      systemUsers = {
        # generate the `hashedPassword` using `mkpasswd`
        root.hashedPassword     = "$y$j9T$pu6FzqviKwK3OJFd/iRjc.$9AS4GXVkjYhrFKK/apJzQj3a8eTikI2S0jBhRAS/1e8";
        nixosIso.hashedPassword = "$y$j9T$Cvs/IpcrqGMijUQzTK/QT.$MUR/yeWILyoA8TK/lHGJmA32WR60OOko9WI/z7T0BB9";
        pratham.hashedPassword  = "$y$j9T$OfCucSHxqUwSKja6tw/K..$ookfkYGconxq6oqeRYMUR2WhjwFxiuDsIe9aCBQTVz8";

        nixosIso = {
          username = "nixos";
          fullname = "nixos";
          enableLingering = true;
        };

        # actual, real system users
        pratham = {
          username = "pratham";
          fullname = "Pratham Patel";
          enableLingering = true;
        };
      };

      flakeUri = "/root/prathams-nixos";
      gatewayAddr = "10.0.0.1";
      ipv4PrefixLength = 24;
      nixosHosts = {
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

      # actual filesystems that I use
      supportedFilesystemsSansZFS = [
        "ext4"
        "vfat"
        "xfs"
      ];

      mkNixosSystem = hostname: nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit (nixosHosts."${hostname}") hostname ipv4Address networkingIface hostId system;
          inherit flakeUri gatewayAddr ipv4PrefixLength nixosHosts nixpkgs supportedFilesystemsSansZFS;
          forceLtsKernel = nixosHosts."${hostname}".forceLtsKernel or false;
          systemUser = nixosHosts."${hostname}".systemUser or systemUsers.pratham;
        };

        modules = [
          ./nixos-configuration/hosts/${hostname}/default.nix
          ./nixos-configuration/hosts/hosts-common.nix
          self.nixosModules.customNixosBaseModule
        ] ++ (nixosHosts."${hostname}".extraSystemModules or [ ]);
      };

      mkNonNixosHomeManager = pkgs: systemUser: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit systemUser nixpkgsRelease; };
        modules = [ ./nixos-configuration/home-manager/non-nixos-home.nix ];
      };

      buildNixosSystem = nixosConfigurationName: self.nixosConfigurations."${nixosConfigurationName}".config.system.build.toplevel;
      buildNixosIso = systemArch: self.nixosConfigurations."iso-${systemArch}".config.system.build.isoImage;
      buildHomeOf = system: username: self.legacyPackages."${system}".homeConfigurations."${username}".activationPackage;
    in
    {
      nixosModules = {
        customNixosBaseModule = {
          _module.args = { inherit home-manager nixpkgsRelease; };

          imports = [
            {
              system.stateVersion = "${nixpkgsRelease}";
              hardware.enableRedistributableFirmware = true;
              nixpkgs.config.allowUnfree = true; # allow non-FOSS pkgs
              users.users.root.hashedPassword = "${systemUsers.root.hashedPassword}";
            }
            ./nixos-configuration/configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true; # use the system's instance for pkgs
              imports = [
                ./nixos-configuration/home-manager/nixos-home.nix
              ];
            }
          ];
        };

        customNixosIsoModule = {
          _module.args = {
            inherit supportedFilesystemsSansZFS;
          };

          imports = [
            ./nixos-configuration/_iso/iso.nix
          ];
        };
      };

      nixosConfigurations = {
        flameboi = mkNixosSystem "flameboi";
        sentinel = mkNixosSystem "sentinel";
        reddish = mkNixosSystem "reddish";
        mahadev = mkNixosSystem "mahadev";
        pawandev = mkNixosSystem "pawandev";
        stuti = mkNixosSystem "stuti";
        chaturvyas = mkNixosSystem "chaturvyas";
        vaaman = mkNixosSystem "vaaman";
        vaayu = mkNixosSystem "vaayu";

        iso-aarch64 = nixpkgs.lib.nixosSystem { system = linuxSystems.aarch64; modules = [ self.nixosModules.customNixosIsoModule ]; };
        iso-riscv64 = nixpkgs.lib.nixosSystem { system = linuxSystems.riscv64; modules = [ self.nixosModules.customNixosIsoModule ]; };
        iso-x86_64 = nixpkgs.lib.nixosSystem { system = linuxSystems.x86_64; modules = [ self.nixosModules.customNixosIsoModule ]; };
      };

      machines = {
        flameboi = buildNixosSystem "flameboi";
        sentinel = buildNixosSystem "sentinel";
        reddish = buildNixosSystem "reddish";
        mahadev = buildNixosSystem "mahadev";
        pawandev = buildNixosSystem "pawandev";
        stuti = buildNixosSystem "stuti";
        chaturvyas = buildNixosSystem "chaturvyas";
        vaaman = buildNixosSystem "vaaman";
        vaayu = buildNixosSystem "vaayu";
      };
      isos = {
        aarch64 = buildNixosIso "aarch64";
        riscv64 = buildNixosIso "riscv64";
        x86_64 = buildNixosIso "x86_64";
      };

      packages = forEachSupportedSystem ({ pkgs, ... }: {
        rpi4UBootInBoot = pkgs.writeShellScriptBin "rpi-4-u-boot-in-boot" ''
          set -e

          # TODO: "fix" upstream nixpkgs to produce a generic "AIO" U-Boot image that works on all 64-bit RPis
          # basically enough to uncomment the following lines
          #if grep -q 'raspberrypi' /proc/device-tree/compatible; then
          #    cp ''${pkgs.ubootRaspberryPi64bit}/u-boot.bin /boot

          if grep -q 'bcm2711' /proc/device-tree/compatible; then
              cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin /boot
              cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/* /boot
              cat << EOF > /boot/config.txt
                  enable_uart=1
                  avoid_warnings=1
                  arm_64bit=1
                  kernel=u-boot.bin

                  [pi4]
                  hdmi_enable_4kp60=1
                  arm_boost=1
          EOF
          fi
        '';
      });

      legacyPackages = forEachSupportedSystem ({ pkgs, ... }: {
        homeConfigurations."${systemUsers.pratham.username}" = mkNonNixosHomeManager pkgs systemUsers.pratham;
      });
      homeOf = forEachSupportedSystem ({ pkgs, ... }: {
        pratham = buildHomeOf pkgs.system "pratham";
      });

      devShells = forEachSupportedSystem ({ pkgs, ... }: {
        default = pkgs.mkShell {
          packages = with pkgs; [ just ];

          env = {
            UPDATE_LOCKFILE = 0;
            USE_NOM_INSTEAD = 1;
            DO_DRY_RUN = 1;
          };
        };
      });
    };
}
