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
  version = "0.1.0-unstable-2026-09-10";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "nixos-install-tfg";
    rev = "4d8aac14743fd543e1a9a09a4a49ca63ea6ecb85";
    hash = "sha256-BkbUlQ1BAwitUe3myLkjLkq6ByXx8VNnMbMnEmOnA2Y=";
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
