{
  # installer
  nixos-install-tfg,

  # utilities necessary for installation
  dash,
  hdparm,
  parted,
  python3,

  # getting, modifying and running the installer
  git,
  neovim,
  ripgrep,
  rsync,
  tmux,
  vim,

  # extra misc
  dmidecode,
  memtester,
  pciutils,

  # monitoring
  btop,
  htop,
}:

[
  btop
  dash
  dmidecode
  git
  hdparm
  htop
  memtester
  neovim
  nixos-install-tfg
  parted
  pciutils
  python3
  ripgrep
  rsync
  tmux
  vim
]
++ nixos-install-tfg.buildInputs
++ nixos-install-tfg.nativeBuildInputs
++ nixos-install-tfg.propagatedBuildInputs
++ nixos-install-tfg.propagatedNativeBuildInputs
