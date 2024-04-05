{ config
, lib
, pkgs
, modulesPath
, supportedFilesystemsSansZFS
, ...
}:

{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

  environment.systemPackages = with pkgs; [
    # utilities necessary for installation
    hdparm
    parted

    # getting, modifying and running the installer
    git
    neovim
    rsync
    tmux
    vim

    # monitoring
    btop
    htop
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # since the latest kernel package is installed, there will be a ZFS conflict because
    # 1. ZFS is developed out of tree and needs to catch up to the latest release
    # 2. NixOS has ZFS enabled as a default
    # so force a list of filesystems which I use; sans-ZFS
    supportedFilesystems = lib.mkForce supportedFilesystemsSansZFS;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  isoImage.squashfsCompression = "zstd -Xcompression-level 22";
}
