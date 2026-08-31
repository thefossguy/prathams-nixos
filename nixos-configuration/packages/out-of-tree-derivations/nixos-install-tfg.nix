{
  rustPlatform,
  fetchFromCodeberg,
  lib,

  # buildInputs
  btrfs-progs,
  dosfstools,
  git,
  nix,
  nixos-install,
  parted,
  systemd,
  util-linux,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nixos-install-tfg";
  version = "0.1.0-unstable-2026-08-31";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "nixos-install-tfg";
    rev = "fcd47ee112d98340e5b5692dbba511e7a0242025";
    hash = "sha256-Ik/2YatYeIgXVOKL/uhUwyZk5+80Q0gOeIKzwTj+uCU=";
  };

  cargoHash = "sha256-W+gPUQOZTxLfTG4kPUIjopHWAhvtLgQ3Ab6V2Pm2xLc=";

  buildInputs = [
    btrfs-progs
    dosfstools
    git
    nix
    nixos-install
    parted
    systemd
    util-linux
  ];

  meta = {
    homepage = "https://codeberg.org/thefossguy/nixos-install-tfg";
    description = "thefossguy's NixOS installer";
    mainProgram = "nixos-install-tfg";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux;
  };
})
