{ config
, lib
, pkgs
, modulesPath
, supportedFilesystemsSansZFS
, ...
}:

let
  getGitRepos = pkgs.writeShellScriptBin "getGitRepos" ''
    set -xeuf -o pipefail

    while ! ping 1.1.1.1 -c 1 1>/dev/null || ! ping 8.8.8.8 -c 1 1>/dev/null; do
        sleep 1
    done

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
in

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
  isoImage.squashfsCompression = "zstd -Xcompression-level 22";
}
