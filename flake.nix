{
  inputs = {
    nixpkgs.url = "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";
    home-manager = {
      url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-stable.url = "https://nixos.org/channels/nixos-25.05/nixexprs.tar.xz";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixpkgs-stable,
      self,
      ...
    }:
    let
      mkForEachSupportedSystem =
        supportedSystems: f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
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
            nixpkgs
            home-manager
            nixpkgs-stable
            linuxSystems
            fullUserSet
            hostname
            nixBuildArgs
            ;
        };

      mkNixosIso =
        {
          system,
          nixpkgsInputChannel ? "default",
          compressIso ? false,
          guiSession ? "unset", # Value of `config.customOptions.displayServer.guiSession` NixOS option
        }:
        import ./functions/make-iso-system.nix {
          inherit
            nixpkgs
            nixpkgs-stable
            linuxSystems
            fullUserSet
            nixBuildArgs
            ;
          inherit system;
          inherit compressIso;
          inherit guiSession;
        };

      mkNonNixosHomeManager =
        {
          system,
          userSet,
        }:
        import ./functions/make-home-system.nix {
          inherit
            nixpkgs
            home-manager
            nixpkgs-stable
            system
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
          realUserSet = (nixpkgs.lib.filterAttrs (userName: userSet: userSet.isRealUser) fullUserSet);
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
            system,
          }:
          {
          }
        )
        // forEachSupportedLinuxSystem (
          {
            pkgs,
            system,
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
          system,
        }:
        {
        }
      );

      miscPackages =
        forEachSupportedUnixSystem (
          {
            pkgs,
            system,
          }:
          {
          }
        )
        // forEachSupportedLinuxSystem (
          {
            pkgs,
            system,
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
          system,
        }:
        {
          minimal = mkNixosIso {
            inherit system;
          };
          minimalCompressed = mkNixosIso {
            inherit system;
            compressIso = true;
          };
          cosmic = mkNixosIso {
            inherit system;
            guiSession = "cosmic";
          };
          cosmicCompressed = mkNixosIso {
            inherit system;
            guiSession = "cosmic";
            compressIso = true;
          };
        }
      );

      kexecTree = forEachSupportedLinuxSystem (
        {
          pkgs,
          system,
          ...
        }:
        {
          default = self.kexecTree."${system}".minimal;
          minimal = nixpkgs.lib.nixosSystem {
            modules = [
              "${nixpkgs}/nixos/modules/installer/netboot/netboot-minimal.nix"
              ./nixos-configuration/modules/kexec-image/default.nix
              { nixpkgs.hostPlatform.system = "${system}"; }
            ];

          };
        }
      );

      apps = forEachSupportedUnixSystem (
        {
          pkgs,
          system,
        }:
        {
          nixFormat = {
            type = "app";
            program = "${pkgs.writeShellScript "treewide-nix-format.sh" ''
              set -euf -o pipefail

              PATH=${pkgs.findutils}/bin:${pkgs.nixfmt}/bin:${pkgs.ruff}/bin:${pkgs.shfmt}/bin:$PATH
              export PATH

              find . -iname '*.nix' -type f -print0 | xargs --no-run-if-empty -0 nixfmt --width=120 --indent=2 --verify
              find . -iname '*.py' -type f -print0 | xargs --no-run-if-empty -0 ruff format --no-cache --line-length=120
              find . -iname '*.sh' -type f -print0 | xargs --no-run-if-empty -0 shfmt --write --indent 4 --case-indent --space-redirects
            ''}";
          };
        }
      );
    };
}
