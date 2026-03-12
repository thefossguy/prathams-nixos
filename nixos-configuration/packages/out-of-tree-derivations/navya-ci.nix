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
    rev = "65923d4326722eb4d2af4d032289627e821bc83d";
    hash = "sha256-C+W/xQJ3q21Ik+vd2FKmFDOg7ZJbOctrgE9jY1GoP4w=";
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
