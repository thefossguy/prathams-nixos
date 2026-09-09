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
  version = "0.1.0-unstable-2026-09-09";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "nixos-install-tfg";
    rev = "69c210f72acb873afb2fa23beb4be3f84160b31a";
    hash = "sha256-W89Mot1sMr48Muc6mBb9TlQqUUb5To4oHAaFFzu8nEA=";
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
