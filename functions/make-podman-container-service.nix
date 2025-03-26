{
  lib,
  pkgs,
  containerConfig,
  serviceConfig,
  extraPkgsInPath ? [],
}:

let
  extraPkgsInPath' = extraPkgsInPath ++ [
    "${pkgs.coreutils-full}/bin"
    "${pkgs.podman}/bin"
    "/run/wrappers/bin" # required for a setuid wrapper of `newuidmap`
    "$PATH"
  ];
in

{
  Service = {
    NotifyAccess = "all";
    Restart = "always";
    Type = "notify";

    Environment = [
      # Need to manually assign them to environment variables
      # because sometimes the `%t` doesn't expand
      # so better expand the environment variables with Bash than "systemd ones"
      "PODMAN_SYSTEMD_UNIT=%n"
      "XDG_RUNTIME_DIR=%t"

      "PATH=${builtins.concatStringsSep ":" extraPkgsInPath'}"
    ];

    ExecStartPre = "${pkgs.writeShellScript "${serviceConfig.unitName}-ExecStartPre.sh" ''
      set -xeuf -o pipefail

      # execStartPre
      ${serviceConfig.execStartPre or ""}

      podman load --quiet --input ${containerConfig.containerImage}
    ''}";

    ExecStart = "${pkgs.writeShellScript "${serviceConfig.unitName}-ExecStart.sh" ''
      set -xeuf -o pipefail
      podman run \
        --cgroups no-conmon \
        --cidfile "''${XDG_RUNTIME_DIR}/containers/''${PODMAN_SYSTEMD_UNIT}.ctr-id" \
        --detach \
        --env TZ=Asia/Kolkata \
        --label io.containers.autoupdate=${
          if containerConfig.enableAutoUpdates then "registry" else "disabled"
        } \
        --name ${serviceConfig.unitName} \
        --network ${containerConfig.network} \
        ${
          lib.strings.optionalString (
            containerConfig.network != "host"
          ) "--network-alias ${serviceConfig.unitName}"
        } \
        --pull missing \
        --replace \
        --rm \
        --sdnotify conmon \
        ${containerConfig.extraExecStart}
    ''}";

    ExecStop = "${pkgs.writeShellScript "${serviceConfig.unitName}-ExecStop.sh" ''
      set -xeuf -o pipefail
      podman stop \
        --cidfile "''${XDG_RUNTIME_DIR}/containers/''${PODMAN_SYSTEMD_UNIT}.ctr-id" \
        --ignore \
        --time 120
    ''}";

    ExecStopPost = "${pkgs.writeShellScript "${serviceConfig.unitName}-ExecStopPost.sh" ''
      set -xeuf -o pipefail
      podman rm \
        --cidfile "''${XDG_RUNTIME_DIR}/containers/''${PODMAN_SYSTEMD_UNIT}.ctr-id" \
        --ignore \
        --time 120 \
        --force

      podman rmi ${containerConfig.containerImage.name} || \
          echo 'Failed to remove image, probably being used by another container'
    ''}";
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
