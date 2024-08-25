{ pkgs, ... }:

let
  connectivityCheckScript = import ../modules/misc-imports/check-network.nix { inherit pkgs; };
  getGitRepos = pkgs.writeShellScriptBin "getGitRepos" ''
    set -xeuf -o pipefail

    ${connectivityCheckScript}

    if [[ ! -d "$HOME/.dotfiles" ]]; then
        ${pkgs.gitFull}/bin/git clone --bare https://gitlab.com/thefossguy/dotfiles.git "$HOME/.dotfiles"
        ${pkgs.gitFull}/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout -f
        rm -rf "$HOME/.config/nvim"
    fi

    if [[ ! -d "$HOME/my-git-repos/prathams-nixos" ]]; then
        mkdir -vp "$HOME/my-git-repos"
        ${pkgs.gitFull}/bin/git clone https://gitlab.com/thefossguy/prathams-nixos.git "$HOME/my-git-repos/prathams-nixos"
    fi
  '';
in [ getGitRepos ] ++ (with pkgs; [
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
  memtester
  pciutils

  # monitoring
  btop
  htop
])
