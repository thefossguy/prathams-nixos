{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "navya-ci";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "thefossguy";
    repo = "navya-ci";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Lte6f0KnFgmm8f3RJ56wld8VGnLZXXKGq10uiZPg3p0=";
  };

  cargoHash = "sha256-JKBsdMfT3GNTNu9FlxbyPznu4Mo6W3yK9tBIVgMDBEs=";

  meta = {
    homepage = "https://codeberg.org/thefossguy/navya-ci";
    description = "A scriptable Nix CI as a Rust program";
    mainProgram = "navya-ci";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
