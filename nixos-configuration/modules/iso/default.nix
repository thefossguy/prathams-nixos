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

  isoImage = {
    squashfsCompression = "zstd -Xcompression-level 22"; # Highest compression ratio.
    isoName = lib.mkForce "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${config.boot.kernelPackages.kernel.version}-${isoZfsString}${pkgs.stdenv.hostPlatform.system}.iso";

    #squashfsCompression = "lz4 -b 32768"; # Lowest time to compress.
  };
}
