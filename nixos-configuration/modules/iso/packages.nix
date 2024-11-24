{ pkgs, ... }:

let
  connectivityCheckScript = import ../misc-imports/check-network.nix { inherit pkgs; };
  appendedPath = import ../../../functions/append-to-path.nix {
    packages = with pkgs; [
      git
      openssh
      openssl
    ];
  };

  dotfilesDir = "$HOME/.dotfiles";
  nixosDir = "$HOME/prathams-nixos";

  getGitRepos = pkgs.writeShellScriptBin "getGitRepos" ''
    set -xeuf -o pipefail

    ${appendedPath}
    export PATH

    ${connectivityCheckScript}

    if [[ "$(hostname)" == 'nixos' ]]; then
        rm -rf ${dotfilesDir}
        git clone --bare https://gitlab.com/thefossguy/dotfiles.git ${dotfilesDir}
        git --git-dir=${dotfilesDir} --work-tree=$HOME checkout -f
        rm -rf $HOME/.config/nvim

        rm -rf ${nixosDir}
        git clone https://gitlab.com/thefossguy/prathams-nixos.git ${nixosDir}
    fi
  '';
in [ getGitRepos ] ++ (with pkgs; [
  # utilities necessary for installation
  dash
  hdparm
  parted
  python3

  # getting, modifying and running the installer
  git
  neovim
  ripgrep
  rsync
  tmux
  vim

  # extra misc
  dmidecode
  memtester
  pciutils

  # monitoring
  btop
  htop
])
