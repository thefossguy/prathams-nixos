{
  config,
  lib,
  pkgs,
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  kernelPackage = config.boot.kernelPackages.kernel;
in
lib.mkIf config.customOptions.kernelDevelopment.enable {
  environment = {
    variables = {
      KMOD_BUILD_DIR = "${kernelPackage.dev}/lib/modules/${kernelPackage.modDirVersion}/build";
    };

    systemPackages =
      kernelPackage.buildInputs
      ++ kernelPackage.nativeBuildInputs
      ++ kernelPackage.propagatedBuildInputs
      ++ kernelPackage.propagatedNativeBuildInputs;
  };
}
