{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

{
  systemd = {
    tmpfiles.settings = {
      "00-system-gc-roots" = {
        "/tmp/gc-roots"."D" = {
          mode = "1777";
          age = "14d";
        };
      };
    };
    user.tmpfiles.users."${nixosSystemConfig.coreConfig.systemUser.username}".rules = [
      "D %h/.tmp/gc-roots 0755 %u %u - -"
    ];
  };
}
