{
  config,
  lib,
  pkgs,
  osConfig ? { },
  pkgsChannels,
  nixosSystemConfig,
  ...
}:

let
  enableHomelabServices = osConfig.customOptions.podmanContainers.enableHomelabServices or false;
  containersPolicy = {
    default = [
      {
        type = "insecureAcceptAnything";
      }
    ];
  };
in

{
  imports = [
    ../../packages/user-packages.nix
    ../services/user
  ];

  home.stateVersion = lib.versions.majorMinor lib.version;
  home.username = nixosSystemConfig.coreConfig.systemUser.username;

  xdg.configFile = lib.attrsets.optionalAttrs enableHomelabServices {
    "containers/policy.json" = {
      enable = true;
      text = builtins.toJSON containersPolicy;
    };
  };
}
