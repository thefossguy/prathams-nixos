{
  config,
  lib,
  pkgs,
  stablePkgs,
  nixosSystemConfig,
  ...
}:

let
  serviceConfig = lib.recursiveUpdate nixosSystemConfig.extraConfig.allServicesSet.nixGc ({unitName = "user-nix-gc";});
in

lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  systemd.user = {
    timers."${serviceConfig.unitName}" = {
      Install = {
        RequiredBy = [ "timers.target" ];
      };
      Timer = {
        Unit = "${serviceConfig.unitName}.service";
        OnCalendar = serviceConfig.onCalendar;
      };
    };

    services."${serviceConfig.unitName}" = {
      Service = {
        Type = "oneshot";
        ExecStart = "${lib.getExe' pkgs.nix "nix-collect-garbage"} ${nixosSystemConfig.extraConfig.nixGcOptions}";
      };
    };
  };
}
