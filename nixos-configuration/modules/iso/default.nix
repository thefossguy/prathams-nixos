{ config, lib, modulesPath, pkgs, pkgsChannels, nixosSystemConfig, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../qemu/qemu-guest.nix
  ];

  environment.systemPackages = pkgs.callPackage ./packages.nix { inherit pkgs pkgsChannels; };
  # `initialHashedPassword` is used because that is what upstream (nixpkgs) sets and what should be overwritten.
  users.users."${nixosSystemConfig.coreConfig.systemUser.username}".initialHashedPassword = lib.mkForce nixosSystemConfig.coreConfig.systemUser.hashedPassword;
  # Systems with memory less than 8G get an OOM kill on running `nixos-install`
  # so instead of having one swap device, use two swap devices.
  zramSwap.swapDevices = 2;
  nix.settings.cores = 1;

  # I hate to have home-manager since it is not **necessary** but it is the only
  # way that _I know_ how to create a file in $HOME in NixOS.
  home-manager = {
    useGlobalPkgs = true;
    users."${nixosSystemConfig.coreConfig.systemUser.username}" = { config, lib, osConfig, pkgs, ... }: {
      home.stateVersion = lib.versions.majorMinor lib.version;
      home.file.".profile" = {
        enable = true;
        force = true;
        executable = true;
        text = ''
          set -x

          if ! ${pkgs.iputils}/bin/ping -c 5 'gitlab.com' 1>/dev/null 2>&1; then
              set +x
              echo 'You do not appear to be connected to the internet.'
              echo 'Please clone the following directories manually:'
              echo ' 1. NixOS Configuration: https://gitlab.com/thefossguy/prathams-nixos.git'
              echo ' 2. Dotfiles: https://gitlab.com/thefossguy/dotfiles.git'
              exec bash
          fi

          NIXOS_CONFIG_DIR="$HOME/.prathams-nixos"
          DOTFILES_DIR="$HOME/.dotfiles"

          NIXOS_CONFIG_REPO_URL='https://gitlab.com/thefossguy/prathams-nixos.git'
          DOTFILE_REPO_URL='https://gitlab.com/thefossguy/dotfiles.git'

          git clone "$NIXOS_CONFIG_REPO_URL" "$NIXOS_CONFIG_DIR" || \
              (rm -rf "$NIXOS_CONFIG_DIR" && git clone "$NIXOS_CONFIG_REPO_URL" "$NIXOS_CONFIG_DIR")

          git clone --bare "$DOTFILE_REPO_URL" "$DOTFILES_DIR" || \
              (rm -rf "$DOTFILES_DIR" && git clone --bare "$DOTFILE_REPO_URL" "$DOTFILES_DIR")

          git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout -f
          rm -rf "$HOME/.config/nvim"
          set +x
          exec bash
        '';
      };
    };
  };

  isoImage = {
    squashfsCompression = "zstd -Xcompression-level 22"; # Highest compression ratio.
    isoName = lib.mkForce "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${nixosSystemConfig.kernelConfig.kernelVersion}-${config.boot.kernelPackages.kernel.version}-${pkgs.stdenv.hostPlatform.system}.iso";

    #squashfsCompression = "lz4 -b 32768"; # Lowest time to compress.
  };
}
