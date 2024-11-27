{ pkgs, ... }:

(with pkgs; [
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
