{
  flakeStorePath,
  nixosConfigurations,
}:

let
  mkNixosTestVM =
    { nixosConfiguration, extraModulesToPass }:
    nixosConfiguration.extendModules {
      modules = [
        (
          { config, lib, ... }:
          {
            customOptions.isNixOSVMTest = lib.mkForce true;
            assertions = [
              {
                assertion = config.customOptions.isNixOSVMTest;
                message = "Something has unset `config.customOptions.isNixOSVMTest` to which should never happen.";
              }
            ];

            boot.zfs.extraPools = lib.mkForce [ ];
            fileSystems =
              let
                mk9pFS = device: {
                  inherit device;
                  fsType = "9p";
                  neededForBoot = true;
                  options = [
                    "trans=virtio"
                    "version=9p2000.L"
                  ];
                };
              in
              lib.mkForce {
                "/" = {
                  device = "tmpfs";
                  fsType = "tmpfs";
                  options = [ "mode=0755" ];
                };
                "/nix/store" = mk9pFS "nix-store";
                "/tmp/shared" = mk9pFS "tmp-shared";
              };

            virtualisation.vmVariant.virtualisation = {
              diskImage = lib.mkForce null;
              useBootLoader = lib.mkForce false;
              graphics = lib.mkForce false;
              memorySize = lib.mkForce 2048;
              cores = lib.mkForce 1;
            };
          }
        )
      ]
      ++ extraModulesToPass;
    };
in

{
  systemdTmpfilesStateVerifier = import ./systemd-tmpfiles-state-verifier.nix {
    inherit mkNixosTestVM flakeStorePath nixosConfigurations;
  };
}
