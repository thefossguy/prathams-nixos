{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "navya-ci";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "thefossguy";
    repo = "navya-ci";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OhLe021serp/zd2y/FWAsdASz/JNsl/fNbJaXA19/uE=";
  };

  cargoHash = "sha256-s7EyQY4PMppjS4Q+EHwFUufXCkD5Qk4znHCDhrHBBgY=";

  meta = {
    homepage = "https://codeberg.org/thefossguy/navya-ci";
    description = "A scriptable Nix CI as a Rust program";
    mainProgram = "navya-ci";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.thefossguy ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
