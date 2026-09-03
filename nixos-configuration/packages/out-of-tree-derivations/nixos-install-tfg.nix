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
  version = "0.1.0-unstable-2026-09-03";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "nixos-install-tfg";
    rev = "556d699b4881657f59e8be235ecbe5ec4b46c4cf";
    hash = "sha256-zBGamgmAYSBOhHtEUbuCB6rq3ylSY9h5bEaBZN/zcic=";
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
