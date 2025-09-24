{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  kernelPackage = config.boot.kernelPackages.kernel;
in
lib.mkIf config.customOptions.kernelDevelopment.enable {
  environment = {
    variables = {
      KDIR = "${kernelPackage.dev}/lib/modules/${kernelPackage.modDirVersion}/build";
    };

    systemPackages =
      kernelPackage.buildInputs
      ++ kernelPackage.nativeBuildInputs
      ++ kernelPackage.propagatedBuildInputs
      ++ kernelPackage.propagatedNativeBuildInputs;
  };
}
