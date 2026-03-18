{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "navya-ci";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "thefossguy";
    repo = "navya-ci";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4S8Irtu+JcZsSxCBHiPh3r/e5gfUKUwGVsImRBsofU8=";
  };

  cargoHash = "sha256-yYZSpdG0iBkLBCsdXGjKD4Sgbnaiy57G0XeVFkj5Qho=";

  meta = {
    homepage = "https://codeberg.org/thefossguy/navya-ci";
    description = "A scriptable Nix CI as a Rust program";
    mainProgram = "navya-ci";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
