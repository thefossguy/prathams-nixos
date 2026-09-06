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
