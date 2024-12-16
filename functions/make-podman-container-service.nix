{ pkgs, serviceConfig }:

{
  Service = {
    NotifyAccess = "all";
    Restart = "always";
    Type = "notify";

    Environment = [
      "PODMAN_SYSTEMD_UNIT=%n"
      ''PATH="${pkgs.podman}/bin:$PATH"''
    ];

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

    ExecStart = ''
      podman run \
        --cgroups no-conmon \
        --cidfile %t/%n.ctr-id \
        --detach \
        --env TZ=Asia/Kolkata \
        --label io.containers.autoupdate=registry \
        --name ${serviceConfig.containerConfig.name} \
        --network containers_default \
        --network-alias ${serviceConfig.containerConfig.name} \
        --pull missing \
        --replace \
        --rm \
        --sdnotify conmon \
        ${serviceConfig.containerConfig.extraExecStart}
    '';
  };

  Install = {
    WantedBy = [ "default.target" ];
    RequiredBy = serviceConfig.containerConfig.requiredBy or [];
  };

  Unit = {
    Description = "Container service for ${serviceConfig.containerConfig.description}";
    Documentation = [ "man:podman-run(1)" "man:podman-stop(1)" "man:podman-rm(1)" ];
    After = serviceConfig.containerConfig.after;
    Wants = serviceConfig.containerConfig.wants or [];
    Requires = serviceConfig.containerConfig.requires or [];
    RequiresMountsFor = [ "%t/containers" ];
  };
}
