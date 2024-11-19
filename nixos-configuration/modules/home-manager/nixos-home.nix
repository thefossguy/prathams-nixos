{ config, lib, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit pkgsChannels nixosSystemConfig; };

    users."${nixosSystemConfig.coreConfig.systemUser.username}" = { config, lib, osConfig, pkg, pkgsChannels, nixosSystemConfig, ... }: {
      imports = [
        ./common-home.nix
        ./virt-ovmf.nix

        # TODO: self-host flakestry.dev so that I don't go over the piddly rate-limit of GitHub
        #../services/user/podman/container-caddy-vishwambhar.nix
        #../services/user/podman/container-gitea-chitragupta.nix
        #../services/user/podman/container-gitea-govinda.nix
        #../services/user/podman/container-hugo-mahayogi.nix
        #../services/user/podman/container-hugo-vaikunthnatham.nix
        #../services/user/podman/container-transmission-raadhe.nix
        #../services/user/podman/container-uptime-vishnu.nix
        #../services/user/podman/podman-init.nix
      ];
    };
  };
}
