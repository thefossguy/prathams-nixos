{ config
, lib
, pkgs
, nixpkgsRelease
, systemUser
, ...
}:

let
  mkContainerService =
    { containerDescription
    , containerName
    , extraExecStart
    , installServiceRequiredBy ? []
    , unitAfter
    , unitRequires ? []
    , unitWants ? []
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
in

{
  home-manager.extraSpecialArgs = { inherit systemUser nixpkgsRelease; };
  home-manager.users.${systemUser.username} = { config, lib, pkgs, ... }: {
    imports = [
      ./common-home.nix
      ./virt-ovmf.nix

      # TODO: self-host flakestry.dev so that I don't go over the piddly rate-limit of GitHub
      ../systemd-services/podman/podman-init.nix
      ../systemd-services/podman/container-caddy-vishwambhar.nix
      ../systemd-services/podman/container-gitea-chitragupta.nix
      ../systemd-services/podman/container-gitea-govinda.nix
      ../systemd-services/podman/container-hugo-mahayogi.nix
      ../systemd-services/podman/container-hugo-vaikunthnatham.nix
      ../systemd-services/podman/container-transmission-raadhe.nix
      ../systemd-services/podman/container-uptime-vishnu.nix
    ];

    _module.args = { inherit mkContainerService; };
  };
}
