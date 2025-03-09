{
  lib,
  pkgs,
  containerConfig,
  serviceConfig,
}:

{
  Service = {
    NotifyAccess = "all";
    Restart = "always";
    Type = "notify";

    Environment = [
      "PODMAN_SYSTEMD_UNIT=%n"
      "PATH=${
        builtins.concatStringsSep ":" [
          "${pkgs.coreutils-full}/bin"
          "${pkgs.podman}/bin"
          "/run/wrappers/bin" # required for a setuid wrapper of `newuidmap`
          "$PATH"
        ]
      }"
    ];

    ExecStart = ''
      podman run \
        --cgroups no-conmon \
        --cidfile %t/%n.ctr-id \
        --detach \
        --env TZ=Asia/Kolkata \
        ${lib.strings.optionalString containerConfig.enableAutoUpdates "--label io.containers.autoupdate=registry"} \
        --name ${containerConfig.name} \
        --network containers_default \
        --network-alias ${containerConfig.name} \
        --pull missing \
        --replace \
        --rm \
        --sdnotify conmon \
        ${containerConfig.extraExecStart}
    '';

    ExecStop = ''
      podman stop \
        --cidfile %t/%n.ctr-id \
        --ignore \
        --time 120
    '';

    ExecStopPost = ''
      podman rm \
        --cidfile %t/%n.ctr-id \
        --ignore \
        --time 120 \
        --force
    '';
  };

  Install = {
    WantedBy = serviceConfig.wantedByUnits;
    RequiredBy = serviceConfig.requiredByUnits;
  };

  Unit = {
    Description = "Container service for ${containerConfig.description}";
    Documentation = [
      "man:podman-run(1)"
      "man:podman-stop(1)"
      "man:podman-rm(1)"
    ];
    Before = serviceConfig.beforeUnits;
    After = serviceConfig.afterUnits;
    Wants = serviceConfig.wantedUnits;
    Requires = serviceConfig.requiredUnits;
    RequiresMountsFor = [ "%t/containers" ];
  };
}
