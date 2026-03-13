{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "navya-ci";
  version = "0.1.0-unstable-2026-03-12";

  src = fetchFromGitHub {
    owner = "thefossguy";
    repo = "navya-ci";
    rev = "d1bc078338eb9ede07f886b7d53d680e143d88fa";
    hash = "sha256-FNsL5NC/A3N910voRB/+PO3t/giFpzxa37dOVLd6nxg=";
  };

  cargoHash = "sha256-016K+WSpamEEizXQl4U2w2kaClkEV/fOuk8/e9N4Gfc=";

  meta = {
    homepage = "https://codeberg.org/thefossguy/navya-ci";
    description = "A scriptable Nix CI as a Rust program";
    mainProgram = "navya-ci";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
