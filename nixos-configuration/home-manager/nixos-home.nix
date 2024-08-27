{ pkgs, nixosSystem, ... }:

let
  mkContainerService = {
     containerDescription,
     containerName,
     extraExecStart,
     installServiceRequiredBy ? [ ],
     unitAfter,
     unitRequires ? [ ],
     unitWants ? [ ]
    }:
    {
      Install = {
        RequiredBy = installServiceRequiredBy;
        WantedBy = [ "default.target" ];
      };

      Service = {
        Environment = [ "PODMAN_SYSTEMD_UNIT=%n" ];
        NotifyAccess = "all";
        Restart = "always";
        Type = "notify";

        ExecStop = ''
          ${pkgs.podman}/bin/podman stop \
            --cidfile %t/%n.ctr-id \
            --ignore \
            --time 120
        '';

        ExecStopPost = ''
          ${pkgs.podman}/bin/podman rm \
            --cidfile %t/%n.ctr-id \
            --ignore \
            --time 120 \
            --force
        '';

        ExecStart = ''
          ${pkgs.podman}/bin/podman run \
            --cgroups no-conmon \
            --cidfile %t/%n.ctr-id \
            --detach \
            --env TZ=Asia/Kolkata \
            --label io.containers.autoupdate=registry \
            --name ${containerName} \
            --network containers_default \
            --network-alias ${containerName} \
            --pull missing \
            --replace \
            --rm \
            --sdnotify conmon \
            ${extraExecStart}
        '';
      };

      Unit = {
        Description = "Container service for ${containerDescription}";
        Documentation = [ "man:podman-run(1)" "man:podman-stop(1)" "man:podman-rm(1)" ];
        Requires = unitRequires;
        Wants = unitWants;
        After = unitAfter;
        RequiresMountsFor = [ "%t/containers" ];
      };
    };

in {
  home-manager.extraSpecialArgs = { inherit (nixosSystem) systemUser; };
  home-manager.useGlobalPkgs = true;
  home-manager.users.${nixosSystem.systemUser.username} = { config, lib, pkgs, osConfig, ... }: {
    imports = [
      ./common-home.nix
      ./virt-ovmf.nix
    ] ++ (lib.optionals osConfig.custom-options.enableWebRemoteServices [
      # TODO: self-host flakestry.dev so that I don't go over the piddly rate-limit of GitHub
      ../modules/services/podman/podman-init.nix
      ../modules/services/podman/container-caddy-vishwambhar.nix
      ../modules/services/podman/container-gitea-chitragupta.nix
      ../modules/services/podman/container-gitea-govinda.nix
      ../modules/services/podman/container-hugo-mahayogi.nix
      ../modules/services/podman/container-hugo-vaikunthnatham.nix
      ../modules/services/podman/container-transmission-raadhe.nix
      ../modules/services/podman/container-uptime-vishnu.nix
    ]);

    _module.args = { inherit mkContainerService; };
  };
}
