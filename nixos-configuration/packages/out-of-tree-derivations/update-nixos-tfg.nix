{
  rustPlatform,
  fetchFromCodeberg,
  lib,

  # buildInputs
  git,
  hostname-debian,
  nixos-rebuild-ng,
  util-linux,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "update-nixos-tfg";
  version = "0.1.0-unstable-2026-09-13";

  src = fetchFromCodeberg {
    owner = "thefossguy";
    repo = "update-nixos-tfg";
    rev = "2d061cf7c80791cbd22fd9e25edfa4671371f124";
    hash = "sha256-eCzFF06DI88rY6n8zVv/l+WLRCWhA/JWtEs1Cn50fmk=";
  };

  cargoHash = "sha256-/ML5So4h7xLgdOAzTvNAWiNeTPVmWdK7T5zUBfoCM8k=";

  buildInputs = [
    git
    hostname-debian
    nixos-rebuild-ng
    util-linux
  ];

  meta = {
    homepage = "https://codeberg.org/thefossguy/update-nixos-tfg";
    description = "thefossguy's NixOS updater";
    mainProgram = "update-nixos-tfg";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux;
  };
})
