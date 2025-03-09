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
in

{
  imports = [
  ];

  home.packages = lib.optionals enableHomelabServices (
    with pkgs;
    [
      ctop
      podman
      podman-compose
      podman-tui
    ]
    ++ lib.optionals (osConfig.customOptions.useMinimalConfig or false) [

      buildah
    ]
  );

  xdg.configFile = lib.attrsets.optionalAttrs enableHomelabServices {
    "containers/policy.json" = {
      enable = true;
      text = ''
        {
          "default": [
            "type": "insecureAcceptAnything"
          ]
        }
      '';
    };
  };
}
