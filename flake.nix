{
  inputs = {
    # stable channel
    nixpkgsStable.url = "github:NixOS/nixpkgs/nixos-24.11";
    homeManagerStable = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgsStable";
    };

    # stable-small
    nixpkgsStableSmall.url = "github:NixOS/nixpkgs/nixos-24.11-small";
    homeManagerStableSmall = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgsStableSmall";
    };

    # unstable channel
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    homeManagerUnstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
    };

    # unstable-small
    nixpkgsUnstableSmall.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    homeManagerUnstableSmall = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgsUnstableSmall";
    };
  };

  outputs =
    {
      nixpkgsStable,
      homeManagerStable,
      nixpkgsUnstable,
      homeManagerUnstable,
      nixpkgsStableSmall,
      homeManagerStableSmall,
      nixpkgsUnstableSmall,
      homeManagerUnstableSmall,
      self,
      ...
    }:
    let
      libGenAttrs = allInputChannels.default.nixpkgs.lib.genAttrs;
      libFilterAttrs = allInputChannels.default.nixpkgs.lib.filterAttrs;
      allInputChannels = {
        default = allInputChannels.unstable;
        stable = {
          nixpkgs = nixpkgsStable;
          homeManager = homeManagerStable;
        };
        unstable = {
          nixpkgs = nixpkgsUnstable;
          homeManager = homeManagerUnstable;
        };
        stableSmall = {
          nixpkgs = nixpkgsStableSmall;
          homeManager = homeManagerStableSmall;
        };
        unstableSmall = {
          nixpkgs = nixpkgsUnstableSmall;
          homeManager = homeManagerUnstableSmall;
        };
      };

      mkPkgs = { system, passedNixpkgs }: import passedNixpkgs { inherit system; };

      mkForEachSupportedSystem =
        supportedSystems: f:
        libGenAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = mkPkgs {
              inherit system;
              passedNixpkgs = allInputChannels.default.nixpkgs;
            };
            pkgsStable = mkPkgs {
              inherit system;
              passedNixpkgs = allInputChannels.stable.nixpkgs;
            };
            pkgsUnstable = mkPkgs {
              inherit system;
              passedNixpkgs = allInputChannels.unstable.nixpkgs;
            };
            pkgsStableSmall = mkPkgs {
              inherit system;
              passedNixpkgs = allInputChannels.stableSmall.nixpkgs;
            };
            pkgsUnstableSmall = mkPkgs {
              inherit system;
              passedNixpkgs = allInputChannels.unstableSmall.nixpkgs;
            };
          }
        );

      linuxSystems = {
        aarch64 = "aarch64-linux";
        riscv64 = "riscv64-linux";
        x86_64 = "x86_64-linux";
      };

      darwinSystems = {
        aarch64 = "aarch64-darwin";
        x86_64 = "x86_64-darwin";
      };

      supportedLinuxSystems = builtins.attrValues linuxSystems;
      supportedDarwinSystems = builtins.attrValues darwinSystems;
      supportedUnixSystems = supportedLinuxSystems ++ supportedDarwinSystems;

      forEachSupportedLinuxSystem = mkForEachSupportedSystem supportedLinuxSystems;
      forEachSupportedDarwinSystem = mkForEachSupportedSystem supportedDarwinSystems;
      forEachSupportedUnixSystem = mkForEachSupportedSystem supportedUnixSystems;

      fullUserSet = import ./functions/full-user-set.nix;

      nixBuildArgs = "--max-jobs 1 --print-build-logs --show-trace --verbose";

      mkNixosSystem =
        hostname:
        import ./functions/make-nixos-system.nix {
          inherit
            allInputChannels
            mkPkgs
            linuxSystems
            fullUserSet
            hostname
            nixBuildArgs
            ;
        };

      mkNixosIso =
        {
          system,
          kernelVersion,
          nixpkgsInputChannel ? "default",
          guiSession ? "unset", # Value of `config.customOptions.displayServer.guiSession` NixOS option
        }:
        import ./functions/make-iso-system.nix {
          inherit
            allInputChannels
            mkPkgs
            linuxSystems
            fullUserSet
            nixBuildArgs
            ;
          inherit system kernelVersion;
          inherit nixpkgsInputChannel;
          inherit guiSession;
        };

      mkNonNixosHomeManager =
        {
          system,
          userSet,
          nixpkgsChannel ? "default",
        }:
        import ./functions/make-home-system.nix {
          inherit
            allInputChannels
            mkPkgs
            system
            nixpkgsChannel
            nixBuildArgs
            ;
          systemUser = userSet;
        };
    in
    {
      nixosConfigurations =
        let
          # Stupidly genius :D
          nixosHosts = (import ./functions/nixos-systems.nix { inherit linuxSystems fullUserSet; }).systems;
        in
        builtins.mapAttrs (hostName: hostSet: mkNixosSystem "${hostName}") nixosHosts
        // {
          #hostName = mkNixosSystem "${hostName}";
        };

      homeConfigurations = forEachSupportedUnixSystem (
        { system, ... }:
        # `userName` is the literal username that gets converted to a String as `${fullUserSet}.${userName}.hashedPassword`
        # `userSet` is the single-user subset, like `${userSubset}.hashedPassword`
        let
          realUserSet = (libFilterAttrs (userName: userSet: userSet.isRealUser) fullUserSet);
        in
        builtins.mapAttrs (
          userName: userSet:
          mkNonNixosHomeManager {
            inherit system userSet;
          }
        ) realUserSet
      );

      devShells =
        forEachSupportedUnixSystem (
          {
            pkgs,
            pkgsStable,
            pkgsUnstable,
            system,
            ...
          }:
          {
          }
        )
        // forEachSupportedLinuxSystem (
          {
            pkgs,
            pkgsStable,
            pkgsUnstable,
            system,
            ...
          }:
          {
            nixosInstaller = pkgs.mkShellNoCC {
              packages = pkgs.callPackage ./nixos-configuration/modules/iso/packages.nix { };
              shellHook = ''
                if ! nix help 1>/dev/null 2>&1; then
                    export nix='nix --extra-experimental-features nix-command --extra-experimental-features flakes'
                    alias nix="''${nix}"
                fi
              '';
            };
          }
        );

      packages = forEachSupportedUnixSystem (
        {
          pkgs,
          pkgsStable,
          pkgsUnstable,
          system,
          ...
        }:
        {
        }
      );

      miscPackages =
        forEachSupportedUnixSystem (
          {
            pkgs,
            pkgsStable,
            pkgsUnstable,
            system,
            ...
          }:
          {
          }
        )
        // forEachSupportedLinuxSystem (
          {
            pkgs,
            pkgsStable,
            pkgsUnstable,
            system,
            ...
          }:
          {
            binfmtCheck = pkgs.writeShellApplication {
              name = "binfmtCheck.sh";
              text = "echo '${system}'";
            };
          }
        );

      isoImages = forEachSupportedLinuxSystem (
        {
          pkgs,
          pkgsStable,
          pkgsUnstable,
          system,
          ...
        }:
        {
          mainline = mkNixosIso {
            inherit system;
            kernelVersion = "mainline";
          };
          stable = mkNixosIso {
            inherit system;
            kernelVersion = "stable";
          };
          longterm = mkNixosIso {
            inherit system;
            kernelVersion = "longterm";
          };

          mainline-cosmic = mkNixosIso {
            inherit system;
            kernelVersion = "mainline";
            guiSession = "cosmic";
          };
          stable-cosmic = mkNixosIso {
            inherit system;
            kernelVersion = "stable";
            guiSession = "cosmic";
          };
          longterm-cosmic = mkNixosIso {
            inherit system;
            kernelVersion = "longterm";
            guiSession = "cosmic";
          };
        }
      );
      apps = forEachSupportedUnixSystem (
        {
          pkgs,
          pkgsStable,
          pkgsUnstable,
          system,
          ...
        }:
        {
          nixFormat = {
            type = "app";
            program = "${pkgs.writeShellScript "treewide-nix-format.sh" ''
              set -euf -o pipefail

              PATH=${pkgs.findutils}/bin:${pkgs.nixfmt-rfc-style}/bin:$PATH
              export PATH

              find . -iname '*.nix' -type f -print0 | xargs --no-run-if-empty -0 nixfmt --width=120 --indent=2 --verify
            ''}";
          };
        }
      );
    };
}
