{ config, lib, pkgs, modulesPath, enableZfs, latestLtsKernel, supportedFilesystemsSansZFS, isoUser, ... }:

let
  isoZfsString = if enableZfs
    then "zfs-"
    else "";
  isoKernelPackage = if enableZfs
    then pkgs."${latestLtsKernel}"
    else pkgs.linuxPackages_latest;
  isoSupportedFilesystems = supportedFilesystemsSansZFS ++ (if enableZfs
    then [ "zfs" ]
    else []);
in

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

  boot.kernelPackages = isoKernelPackage;
  boot.supportedFilesystems = lib.mkForce isoSupportedFilesystems;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  time.timeZone = "Asia/Kolkata";
  users.users."${isoUser.username}".hashedPassword = "${isoUser.hashedPassword}";
  isoImage.isoName = lib.mkForce "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${config.boot.kernelPackages.kernel.version}-${isoZfsString}${pkgs.stdenv.hostPlatform.system}.iso";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    swapDevices = 2;
  };

  isoImage.squashfsCompression = "zstd -Xcompression-level 22"; # for prod
  #isoImage.squashfsCompression = "lz4 -b 32768"; # for dev
}
