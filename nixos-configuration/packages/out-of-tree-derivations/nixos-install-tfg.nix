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
  version = "0.1.0-unstable-2026-09-08";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "nixos-install-tfg";
    rev = "0d1e67039652a6955f557329eb2f14af92fee038";
    hash = "sha256-vpfv2IZwrD8jn6WWLVlfMBgQC6YBqyBn1I8DZgveNFY=";
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
