{ lib, pkgs, modulesPath, supportedFilesystemsSansZFS, isoUser, ... }:

let
  connectivityCheckScript = import ../includes/misc-imports/check-network.nix { inherit pkgs; };

  getGitRepos = pkgs.writeShellScriptBin "getGitRepos" ''
    set -xeuf -o pipefail

    ${connectivityCheckScript}

    if [[ ! -d "$HOME/.dotfiles" ]]; then
        git clone --bare https://gitlab.com/thefossguy/dotfiles.git "$HOME/.dotfiles"
        git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout -f
        rm -rf "$HOME/.config/nvim"
    fi

    if [[ ! -d "$HOME/my-git-repos/prathams-nixos" ]]; then
        mkdir -vp "$HOME/my-git-repos"
        git clone https://gitlab.com/thefossguy/prathams-nixos.git "$HOME/my-git-repos/prathams-nixos"
    fi
  '';

in {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../includes/qemu/qemu-guest.nix
  ];

  users.users."${isoUser.username}".hashedPassword = "${isoUser.hashedPassword}";

  environment.systemPackages = with pkgs; [
    # utilities necessary for installation
    dash
    hdparm
    parted

    # getting, modifying and running the installer
    git
    neovim
    ripgrep
    rsync
    tmux
    vim

    # extra misc
    dmidecode
    pciutils

    # monitoring
    btop
    htop

    # ze script
    getGitRepos
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

  isoImage.squashfsCompression = "zstd -Xcompression-level 22"; # for prod
  #isoImage.squashfsCompression = "lz4 -b 32768"; # for dev
}
