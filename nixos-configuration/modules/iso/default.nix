{ config, lib, modulesPath, pkgs, pkgsChannels, nixosSystemConfig, ... }:

let
  isoZfsString = if nixosSystemConfig.kernelConfig.useLongtermKernel then "zfs-" else "nozfs-";
in {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../qemu/qemu-guest.nix
  ];

  environment.systemPackages = pkgs.callPackage ./packages.nix { inherit pkgs pkgsChannels; };
  users.users."${nixosSystemConfig.coreConfig.systemUser.username}".initialHashedPassword = lib.mkForce nixosSystemConfig.coreConfig.systemUser.hashedPassword;

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
          git clone https://gitlab.com/thefossguy/prathams-nixos.git "$HOME/.prathams-nixos"
          git clone --bare https://gitlab.com/thefossguy/dotfiles.git "$HOME/.dotfiles"
          git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout -f
          rm -rf "$HOME/.config/nvim"
          exec bash
        '';
      };
    };
  };

  isoImage = {
    squashfsCompression = "zstd -Xcompression-level 22"; # Highest compression ratio.
    isoName = lib.mkForce "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${config.boot.kernelPackages.kernel.version}-${isoZfsString}${pkgs.stdenv.hostPlatform.system}.iso";

    #squashfsCompression = "lz4 -b 32768"; # Lowest time to compress.
  };
}
