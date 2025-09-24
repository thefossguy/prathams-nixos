{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

lib.mkIf config.customOptions.enablePasswordlessSudo {
  security.sudo.extraRules = [
    {
      users = [ nixosSystemConfig.coreConfig.systemUser.username ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
